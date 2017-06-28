require 'test_helper'

class TestDatasetTransform < Minitest::Test
  def configure
    @config = {
        url:      ENV['PURE_URL'],
        username: ENV['PURE_USERNAME'],
        password: ENV['PURE_PASSWORD'],
        minting_uri: 'http://data.example.com'
    }
    @transformer = LinkedResearchMetadata::Transformer::Dataset.new @config
  end

  def transform
    configure
    collection_extractor = Puree::Extractor::Collection.new config:   @config,
                                                            resource: :dataset
    dataset = collection_extractor.random_resource
    @graph = @transformer.transform uuid: dataset.uuid
  end

  def test_graph
    transform
    assert_instance_of RDF::Graph, @graph
    assert @graph.size > 0
  end

end