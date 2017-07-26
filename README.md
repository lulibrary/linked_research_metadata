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
  resource_expansion: :min
}
```

```ruby
# Pure host without authentication.
config = {
  url: ENV['PURE_URL'],
  minting_uri: 'http://data.example.com',
  resource_expansion: :min
}
```

#### Parameters
**resource_expansion**

Omit - gives resource URI only.

+ :min - gives resource URI plus type and title/name from the model metadata.
+ :max - gives resource URI plus all model metadata for a resource.

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
