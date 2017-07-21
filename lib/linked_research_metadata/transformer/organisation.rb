module LinkedResearchMetadata
  module Transformer

    # Organisation transformer
    #
    class Organisation < Base

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.
      # @option config [String] :minting_uri The URI at which to mint a resource.
      # @option config [Boolean] :uri_expansion Expand URI with minimal resource metadata.
      def initialize(config)
        super
      end

      # Organisation transformation
      #
      # @param uuid [String]
      # @return [RDF::Graph]
      def transform(uuid:)
        super uuid: uuid, resource: :organisation
      end

      private

      def name
        add_triple @resource_uri, RDF::Vocab::DC.title, @resource.name
      end

      def type
        add_triple @resource_uri, RDF.type, RDF::Vocab::FOAF.Organization
      end

      def build_graph
        name
        type
      end

    end
  end
end
