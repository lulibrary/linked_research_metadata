module LinkedResearchMetadata
  module Transformer

    # Dataset transformer
    #
    class Dataset < Base
      include LinkedResearchMetadata::Transformer::Shared

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.
      # @option config [String] :minting_uri The URI at which to mint a resource.
      # @option config [Boolean] :resource_expansion Expand URI with minimal resource metadata.
      def initialize(config)
        super
      end

      # Dataset transformation
      #
      # @param uuid [String]
      # @return [RDF::Graph]
      def transform(uuid:)
        super uuid: uuid, resource: :dataset
      end

      private

      def available
        object = @resource.available
        if object
          object_literal = RDF::Literal.new(object.strftime("%F"), datatype: RDF::XSD.date)
          add_triple @resource_uri, RDF::Vocab::DC.available, object_literal
        end
      end

      def created
        object =  @resource.created
        if object
          object_literal = RDF::Literal.new(object.strftime("%F"), datatype: RDF::XSD.date)
          add_triple @resource_uri, RDF::Vocab::DC.created, object_literal
        end
      end

      def doi
        if @resource.doi
          doi_uri = RDF::URI.new(@resource.doi)
          doi_predicate_uri = RDF::Vocab::DC.identifier
          add_triple @resource_uri, doi_predicate_uri, doi_uri
        end
      end

      def description
        object = @resource.description
        if object
          object.tr!('\\','') # remove any backslashes
          add_triple @resource_uri, RDF::Vocab::DC.description, object
        end
      end

      def files
        @resource.files.each do |i|
          file_uri = RDF::URI.new(mint_uri(SecureRandom.uuid, :file))

          add_triple @resource_uri, RDF::Vocab::DC.hasPart, file_uri

          minimal_file file_uri, i if @config[:resource_expansion] === :min

          if @config[:resource_expansion] === :max
            minimal_file file_uri, i

            # license
            if i.license && i.license.url
              uri = RDF::URI.new(i.license.url)
              add_triple file_uri, RDF::Vocab::DC.license, uri
            end

            # mime
            add_triple file_uri, RDF::Vocab::DC.format, i.mime

            # size
            size_predicate = RDF::Vocab::DC.extent
            add_triple file_uri, size_predicate, i.size
          end

        end
      end

      def keywords
        @resource.keywords.each do |i|
          add_triple @resource_uri, RDF::Vocab::DC.subject, i
        end
      end

      def projects
        @resource.projects.each do |i|
          project_uri = RDF::URI.new(mint_uri(i.uuid, :project))
          minimal_project project_uri, i  if @config[:resource_expansion] === :min
          if @config[:resource_expansion] === :max && 1===2
            transformer = make_transformer :project
            graph = transformer.transform uuid: i.uuid
            merge_graph graph if graph
          end
          add_triple @resource_uri, RDF::Vocab::DC.relation, project_uri
          @links[:project] << i.uuid
        end
      end

      def publications
        @resource.publications.each do |i|
          if i.type == 'Dataset'
            @links[:dataset] << i.uuid
            publication_uri = RDF::URI.new(mint_uri(i.uuid, :dataset))
          else
            @links[:publication] << i.uuid
            publication_uri = RDF::URI.new(mint_uri(i.uuid, :publication))
          end
          minimal_publication publication_uri, i if @config[:resource_expansion] === :min
          add_triple @resource_uri, RDF::Vocab::DC.relation, publication_uri
        end
      end

      def publisher
        # should be URI
      end

      def roles
        all_persons = []
        all_persons << @resource.persons_internal
        # all_persons << @resource.persons_external
        all_persons << @resource.persons_other
        all_persons.each do |person_type|
          person_type.each do |i|
            if i.uuid
              uuid = i.uuid
              @links[:person] << i.uuid
            else
              uuid = SecureRandom.uuid
            end
            if i.name
              person_uri = RDF::URI.new(mint_uri(uuid, :person))
              minimal_person(person_uri, i) if @config[:resource_expansion] === :min
              if @config[:resource_expansion] === :max
                transformer = make_transformer :person
                graph = transformer.transform uuid: uuid
                merge_graph graph if graph
              end
              if i.role == 'Creator'
                add_triple @resource_uri, RDF::Vocab::DC.creator, person_uri
              end
              if i.role == 'Contributor'
                add_triple @resource_uri, RDF::Vocab::DC.contributor, person_uri
              end
            end
          end
        end
      end

      def spatial
        @resource.spatial_places.each do |i|
          add_triple @resource_uri, RDF::Vocab::DC.spatial, i
        end
      end

      def temporal
        t = @resource.temporal
        temporal_range = ''
        if t
          if t.start
            temporal_range << t.start.strftime("%F")
            if t.end
              temporal_range << '/'
              temporal_range << t.end.strftime("%F")
            end
            object = temporal_range
            add_triple @resource_uri, RDF::Vocab::DC.temporal, object
          end
        end
      end

      def title
        object = @resource.title
        if object
          add_triple @resource_uri, RDF::Vocab::DC.title, object
        end
      end

      def type
        add_triple @resource_uri, RDF.type, RDF::URI.new("#{vocab(:vivo)}Dataset")
      end

      def show_links
        puts 'dataset'
        puts @links
        puts '----- links to graph person start -------'
        puts links_to_graph(:person).dump(:turtle)
        puts '----- links to graph end -------'
        puts '----- links to graph project start -------'
        puts links_to_graph(:project).dump(:turtle)
        puts '----- links to graph end -------'
        puts '----- links to graph dataset start -------'
        puts links_to_graph(:dataset).dump(:turtle)
        puts '----- links to graph end -------'
      end

      def build_graph
        available
        created
        description
        doi
        files
        keywords
        projects
        publications
        # publisher
        roles
        spatial
        temporal
        title
        type
      end

    end
  end
end
