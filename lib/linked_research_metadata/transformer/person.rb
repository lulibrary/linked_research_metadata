module LinkedResearchMetadata
  module Transformer

    # Person transformer
    #
    class Person < Base
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

      # Person transformation
      #
      # @param uuid [String]
      # @return [RDF::Graph]
      def transform(uuid:)
        super uuid: uuid, resource: :person
      end

      private

      def affiliations
        @resource.affiliations.each do |i|
          @links[:organisation] << i.uuid
          organisation_uri = RDF::URI.new(mint_uri(i.uuid, :organisation))
          minimal_organisation organisation_uri, i if @config[:resource_expansion] === :min
          if @config[:resource_expansion] === :max
            transformer = make_transformer :organisation
            graph = transformer.transform uuid: i.uuid
            merge_graph graph if graph
          end
          add_triple @resource_uri, RDF::Vocab::MADS.hasAffiliation, organisation_uri
        end
      end

      def name
        add_triple @resource_uri, RDF::Vocab::FOAF.name, @resource.name.first_last
      end

      def orcid
        if @resource.orcid
          orcid_uri = RDF::URI.new("http://orcid.org/#{@resource.orcid}")
          orcid_predicate_uri = RDF::URI.new("#{vocab(:vivo)}OrcidId")
          add_triple @resource_uri, orcid_predicate_uri, orcid_uri
        end
      end

      def type
        add_triple @resource_uri, RDF.type, RDF::Vocab::FOAF.Person
      end

      def show_links
        puts 'person '
        puts @links
        puts '----- links to graph organisation start -------'
        puts links_to_graph(:organisation).dump(:turtle)
        puts '----- links to graph end -------'
      end

      def build_graph
        affiliations
        name
        orcid
        type
      end

    end
  end
end
