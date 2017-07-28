module LinkedResearchMetadata
  module Transformer

    # Project transformer
    #
    class Project < Base
      include LinkedResearchMetadata::Transformer::Shared

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.
      # @option config [String] :minting_uri The URI at which to mint a resource.
      # @option config [Fixnum] :granularity Expand associated resource URIs with varying amounts of metadata.
      def initialize(config)
        super
      end

      # Project transformation
      #
      # @param uuid [String]
      # @return [RDF::Graph]
      def transform(uuid:)
        super uuid: uuid, resource: :project
      end

      private

      def roles
        all_persons = []
        all_persons << @resource.persons_internal
        all_persons << @resource.persons_external
        all_persons << @resource.persons_other
        all_persons.each do |person_type|
          person_type.each do |i|
            name = i.name.first_last if i.name
            if i.uuid
              uuid = i.uuid
            else
              uuid = SecureRandom.uuid
            end
            if name
              person_uri = RDF::URI.new(mint_uri(uuid, :person))
              if i.role == 'Principal Investigator'
                role_uri = RDF::URI.new("#{vocab(:vivo)}PrincipalInvestigatorRole")
                add_triple @resource_uri, role_uri, person_uri
              end
              if i.role == 'Co-investigator'
                role_uri = RDF::URI.new("#{vocab(:vivo)}CoPrincipalInvestigatorRole")
                add_triple @resource_uri, role_uri, person_uri
              end
              minimal_person(person_uri, i) if @config[:granularity] > 0
            end
            # Phd Student
            # RA
            # Researcher
            # Research Associate
            # Team Member
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
        add_triple @resource_uri, RDF.type, RDF::URI.new("#{vocab(:vivo)}Project")
      end

      def url
        object = @resource.url
        if object
          add_triple @resource_uri, RDF::Vocab::FOAF.homepage, RDF::URI.new(object)
        end
      end

      def build_graph
        roles
        title
        type
        url
      end

    end
  end
end
