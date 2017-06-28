module LinkedResearchMetadata
  module Transformer

    # Base transformer
    #
    class Base

      # @param config [Hash]
      def initialize(config)
        @config = config
        raise 'Minting URI missing' if @config[:minting_uri].empty?
        @graph = RDF::Graph.new
      end

      private

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