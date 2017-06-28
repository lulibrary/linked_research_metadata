module LinkedResearchMetadata
  module Transformer
    class Dataset

      # @param config [Hash]
      def initialize(config)
        @config = config
        raise 'Minting URI missing' if @config[:minting_uri].empty?
        @graph = RDF::Graph.new
      end

      # For a given uuid, fetch the metadata and transform it into an RDF graph
      #
      # @param uuid [String] uuid of dataset
      # @return [RDF::Graph] dataset as an RDF graph
      def transform(uuid:)
        dataset_extractor = Puree::Extractor::Dataset.new @config
        @dataset = dataset_extractor.find uuid: uuid
        raise 'No metadata for ' + uuid if !@dataset
        dataset_uri = mint_uri uuid, :dataset
        @dataset_uri = RDF::URI.new dataset_uri
        build_graph
        @graph
      end

      private

      def available
        object = @dataset.available
        if object
          object_literal = RDF::Literal.new(object.strftime("%F"), datatype: RDF::XSD.date)
          @graph << [ @dataset_uri, RDF::Vocab::DC.available, object_literal ]
        end
      end

      def created
        object =  @dataset.created
        if object
          object_literal = RDF::Literal.new(object.strftime("%F"), datatype: RDF::XSD.date)
          @graph << [ @dataset_uri, RDF::Vocab::DC.created, object_literal ]
        end
      end

      def doi
        if @dataset.doi
          doi_uri = RDF::URI.new @dataset.doi
          doi_predicate_uri = RDF::Vocab::OWL.sameAs
          @graph << [ @dataset_uri, doi_predicate_uri, doi_uri ]
        end
      end

      def description
        object = @dataset.description
        if object
          @graph << [ @dataset_uri, RDF::Vocab::DC.description, object ]
        end
      end

      def files
        @dataset.files.each do |i|
          file_uri = RDF::URI.new mint_uri(SecureRandom.uuid, :file)

          @graph << [ @dataset_uri, RDF::Vocab::DC.hasPart, file_uri ]

          # license
          if i.license && i.license.url
              uri = RDF::URI.new i.license.url
              @graph << [ file_uri, RDF::Vocab::DC.license, uri ]
          end

          # mime
          @graph << [ file_uri, RDF::Vocab::DC.format, i.mime ]

          # size
          @graph << [ file_uri, RDF::Vocab::DC.extent, i.size ]

          #name
          @graph << [ file_uri, RDF::Vocab::RDFS.label, i.name ]
        end
      end

      def keywords
        @dataset.keywords.each do |i|
          @graph << [ @dataset_uri, RDF::Vocab::DC.subject, i ]
        end
      end

      def mint_uri(uuid, resource)
        uri_resource_map = {
            dataset: 'datasets',
            file: 'files',
            organisation: 'organisations',
            person: 'people',
            project: 'projects',
            publication: 'publications'
        }
        File.join @config[:minting_uri], uri_resource_map[resource], uuid
      end

      def person(person_uri, uuid, name)
        @graph << [ person_uri, RDF.type, RDF::Vocab::FOAF.Person ]
        @graph << [ person_uri, RDF::Vocab::FOAF.name, name ]
        person_extractor = Puree::Extractor::Person.new @config
        person = person_extractor.find uuid: uuid
        if person
          person.affiliations.each do |i|
            organisation_uri = RDF::URI.new mint_uri(i.uuid, :organisation)
            @graph << [ person_uri, RDF::Vocab::MADS.hasAffiliation, organisation_uri ]
            @graph << [ organisation_uri, RDF::Vocab::RDFS.label, i.name ]
          end
          if person.orcid
            orcid_uri = RDF::URI.new "http://orcid.org/#{person.orcid}"
            orcid_predicate_uri = RDF::Vocab::OWL.sameAs
            @graph << [ person_uri, orcid_predicate_uri, orcid_uri ]
          end
        end
      end

      def projects
        @dataset.projects.each do |i|
          project_uri = RDF::URI.new mint_uri(i.uuid, :project)
          @graph << [ @dataset_uri, RDF::Vocab::DC.relation, project_uri ]
          @graph << [ project_uri, RDF::Vocab::RDFS.label, i.title ]
          @graph << [ project_uri, RDF.type, RDF::Vocab::FOAF.Project ]
        end
      end

      def publications
        @dataset.publications.each do |i|
          if i.type == 'Dataset'
            publication_uri = RDF::URI.new mint_uri(i.uuid, :dataset)
          else
            publication_uri = RDF::URI.new mint_uri(i.uuid, :publication)
          end
          @graph << [ @dataset_uri, RDF::Vocab::DC.relation, publication_uri ]
          @graph << [ publication_uri, RDF::Vocab::RDFS.label, i.title ]
          # type
          # @graph << [ publication_uri, RDF.type, ??? ]
        end
      end

      def publisher
        # should be URI
      end

      def roles
        all_persons = []
        all_persons << @dataset.persons_internal
        all_persons << @dataset.persons_external
        all_persons << @dataset.persons_other
        all_persons.each do |person_type|
          person_type.each do |i|
            name = i.name.first_last
            if i.uuid
              uuid = i.uuid
            else
              uuid = SecureRandom.uuid
            end
            person_uri = RDF::URI.new mint_uri(uuid, :person)
            if i.role == 'Creator'
              @graph << [ @dataset_uri, RDF::Vocab::DC.creator, person_uri ]
              person person_uri, uuid, name
            end
            if i.role == 'Contributor'
              @graph << [ @dataset_uri, RDF::Vocab::DC.contributor, person_uri ]
              person person_uri, uuid, name
            end
          end
        end

      end

      def spatial
        @dataset.spatial_places.each do |i|
          @graph << [ @dataset_uri, RDF::Vocab::DC.spatial, i ]
        end
      end

      def temporal
        t = @dataset.temporal
        temporal_range = ''
        if t
          if t.start
            temporal_range << t.start.strftime("%F")
            if t.end
              temporal_range << '/'
              temporal_range << t.end.strftime("%F")
            end
            object = temporal_range
            @graph << [ @dataset_uri, RDF::Vocab::DC.temporal, object ]
          end
        end
      end

      def title
        object = @dataset.title
        if object
          @graph << [ @dataset_uri, RDF::Vocab::DC.title, object ]
        end
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
      end

    end
  end
end
