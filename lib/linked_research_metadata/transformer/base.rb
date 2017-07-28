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
      # @option config [Fixnum] :granularity Expand associated resource URIs with varying amounts of metadata.

      def initialize(config)
        @config = config
        @config[:granularity] = 0 if !@config[:granularity]
        raise 'Minting URI missing' if @config[:minting_uri].empty?
        @graph = RDF::Graph.new
        @identifiers = {
            dataset: Set.new,
            organisation: Set.new,
            person: Set.new,
            project: Set.new,
            publication: Set.new
        }
      end

      # Pure UUIDs available after transformation for :dataset, :organisation,
      # :person, :project, :publication.
      #
      # @return [Hash{Symbol => Set<String>}]
      def identifiers
        @identifiers
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
        if @resource
          resource_uri = mint_uri uuid, resource
          @resource_uri = RDF::URI.new(resource_uri)
          build_graph
        end
        @graph
      end

      def merge_graph(graph)
        graph.each { |i| @graph << i }
      end

      def merge_identifiers(identifiers)
        @identifiers.each { |k,v| v.merge identifiers[k] }
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

      def identifiers_to_graph(resource)
        graph = RDF::Graph.new
        @identifiers[resource].each do |i|
          identifiers_graph = RDF::Graph.new
          transformer = make_transformer resource
          graph = transformer.transform uuid: i
          identifiers_graph.each { |i| graph << i }
        end
        graph
      end


    end
  end
end