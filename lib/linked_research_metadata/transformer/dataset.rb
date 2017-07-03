module LinkedResearchMetadata
  module Transformer

    # Dataset transformer
    #
    class Dataset < Base

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.
      # @option config [String] :minting_uri The URI at which to mint a resource.
      def initialize(config)
        super
      end

      # Dataset transformation
      #
      # @param uuid [String]
      # @return [RDF::Graph]
      def transform(uuid:)
        dataset_extractor = Puree::Extractor::Dataset.new @config
        @resource = dataset_extractor.find uuid: uuid
        raise 'No metadata for ' + uuid if !@resource
        dataset_uri = mint_uri uuid, :dataset
        @resource_uri = RDF::URI.new(dataset_uri)
        build_graph
        @graph
      end

      private

      def meta
        add_triple @resource_uri, RDF.type, RDF::URI.new("#{vocab(:vivo)}Dataset")
      end

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

          #name
          add_triple file_uri, RDF::Vocab::DC.title, i.name

          #type
          add_triple file_uri, RDF.type, RDF::Vocab::PREMIS.File
        end
      end

      def keywords
        @resource.keywords.each do |i|
          add_triple @resource_uri, RDF::Vocab::DC.subject, i
        end
      end

      def person(person_uri, uuid, name)
        add_triple person_uri, RDF.type, RDF::Vocab::FOAF.Person
        add_triple person_uri, RDF::Vocab::FOAF.name, name
        person_extractor = Puree::Extractor::Person.new @config
        person = person_extractor.find uuid: uuid
        if person
          person.affiliations.each do |i|
            organisation_uri = RDF::URI.new(mint_uri(i.uuid, :organisation))
            add_triple person_uri, RDF::Vocab::MADS.hasAffiliation, organisation_uri
            add_triple organisation_uri, RDF::Vocab::DC.title, i.name
            add_triple organisation_uri, RDF.type, RDF::Vocab::FOAF.Organization
          end
          if person.orcid
            orcid_uri = RDF::URI.new("http://orcid.org/#{person.orcid}")
            orcid_predicate_uri = RDF::URI.new("#{vocab(:vivo)}OrcidId")
            add_triple person_uri, orcid_predicate_uri, orcid_uri
          end
        end
      end

      def projects
        @resource.projects.each do |i|
          project_uri = RDF::URI.new(mint_uri(i.uuid, :project))
          add_triple @resource_uri, RDF::Vocab::DC.relation, project_uri
          add_triple project_uri, RDF::Vocab::DC.title, i.title
          add_triple project_uri, RDF.type, RDF::URI.new("#{vocab(:vivo)}Project")
        end
      end

      def publications
        @resource.publications.each do |i|
          if i.type == 'Dataset'
            publication_uri = RDF::URI.new(mint_uri(i.uuid, :dataset))
            add_triple publication_uri, RDF.type, RDF::URI.new("#{vocab(:vivo)}Dataset")
          else
            publication_uri = RDF::URI.new(mint_uri(i.uuid, :publication))
            add_triple publication_uri, RDF.type, RDF::URI.new("#{vocab(:swpo)}Publication")
          end
          add_triple @resource_uri, RDF::Vocab::DC.relation, publication_uri
          add_triple publication_uri, RDF::Vocab::DC.title, i.title
        end
      end

      def publisher
        # should be URI
      end

      def roles
        all_persons = []
        all_persons << @resource.persons_internal
        all_persons << @resource.persons_external
        all_persons << @resource.persons_other
        all_persons.each do |person_type|
          person_type.each do |i|
            name = i.name.first_last
            if i.uuid
              uuid = i.uuid
            else
              uuid = SecureRandom.uuid
            end
            person_uri = RDF::URI.new(mint_uri(uuid, :person))
            if i.role == 'Creator'
              add_triple @resource_uri, RDF::Vocab::DC.creator, person_uri
              person person_uri, uuid, name
            end
            if i.role == 'Contributor'
              add_triple @resource_uri, RDF::Vocab::DC.contributor, person_uri
              person person_uri, uuid, name
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

      def build_graph
        meta
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
      end

    end
  end
end
