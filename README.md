# LinkedResearchMetadata

Metadata extraction from the Pure Research Information System and transformation of the metadata into RDF.

## Status

[![Gem Version](https://badge.fury.io/rb/linked_research_metadata.svg)](https://badge.fury.io/rb/linked_research_metadata)
[![Build Status](https://semaphoreci.com/api/v1/aalbinclark/linked_research_metadata/branches/master/badge.svg)](https://semaphoreci.com/aalbinclark/linked_research_metadata)
[![Code Climate](https://codeclimate.com/github/lulibrary/linked_research_metadata/badges/gpa.svg)](https://codeclimate.com/github/lulibrary/linked_research_metadata)

## Installation

Add this line to your application's Gemfile:

    gem 'linked_research_metadata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install linked_research_metadata

## Usage

### Configuration

Create a hash for passing to a transformer.

```ruby
# Pure host with authentication.
config = {
  url:      ENV['PURE_URL'],
  username: ENV['PURE_USERNAME'],
  password: ENV['PURE_PASSWORD'],
  minting_uri: 'http://data.example.com',
  uri_expansion: true
}
```

```ruby
# Pure host without authentication.
config = {
  url: ENV['PURE_URL'],
  minting_uri: 'http://data.example.com',
  uri_expansion: true
}
```

### Transformation

Create a metadata transformer for a Pure dataset.

```ruby
transformer = LinkedResearchMetadata::Transformer::Dataset.new config
```

Give it a Pure identifier...

```ruby
graph = transformer.transform uuid: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
```

...and get an RDF graph.
