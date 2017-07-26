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
      # @option config [Boolean] :resource_expansion Expand URI with minimal resource metadata.

      def initialize(config)
        @config = config
        raise 'Minting URI missing' if @config[:minting_uri].empty?
        @graph = RDF::Graph.new
        @links = {
            dataset: [],
            organisation: [],
            person: [],
            project: [],
            publication: []
        }
      end

      private

      def make_transformer(resource)
        resource_class = "LinkedResearchMetadata::Transformer::#{resource.to_s.capitalize}"
        Object.const_get(resource_class).new @config
      end

      # @param uuid [String]
      # @param resource [Symbol]
      # @return [RDF::Graph]
      def transform(uuid:, resource:)
        resource_class = "Puree::Extractor::#{resource.to_s.capitalize}"
        resource_extractor = Object.const_get(resource_class).new @config
        @resource = resource_extractor.find uuid: uuid
        raise 'No metadata for ' + uuid if !@resource
        resource_uri = mint_uri uuid, resource
        @resource_uri = RDF::URI.new(resource_uri)
        build_graph
        @graph
      end

      def merge_graph(graph)
        graph.each { |i| @graph << i }
      end

      def add_triple(subject, predicate, object)
        @graph << [ subject, predicate, object ]
      end

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

      def links_to_graph(resource)
        graph = RDF::Graph.new
        @links[resource].each do |i|
          links_graph = RDF::Graph.new
          klass = "LinkedResearchMetadata::Transformer::#{resource.to_s.capitalize}"
          transformer =  Object.const_get(klass).new @config
          graph = transformer.transform uuid: i
          links_graph.each { |i| graph << i }
        end
        graph
      end

    end
  end
end