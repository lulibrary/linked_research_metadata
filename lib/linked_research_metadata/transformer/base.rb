module LinkedResearchMetadata
  module Transformer

    # Base transformer
    #
    class Base

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.
      # @option config [String] :minting_uri The URI at which to mint a resource.
      def initialize(config)
        @config = config
        raise 'Minting URI missing' if @config[:minting_uri].empty?
        @graph = RDF::Graph.new
      end

      private

      def vocab(v)
        vocabulary_map =
        {
            swpo: 'http://sw-portal.deri.org/ontologies/swportal#',
            vivo: 'http://vivoweb.org/ontology/core#'
        }
        RDF::Vocabulary.new vocabulary_map[v]
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

    end
  end
end