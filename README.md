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
  granularity: 1
}
```

```ruby
# Pure host without authentication.
config = {
  url: ENV['PURE_URL'],
  minting_uri: 'http://data.example.com',
  granularity: 2
}
```

#### Parameters

**minting_uri**

Prefix for URIs minted e.g.

```
http://data.example.com/datasets/c11d50c1-ade2-493a-ab42-ca54ef233b78
```

UUIDs used are system identifiers wherever possible.


**granularity**

Control how much metadata is put into the graph for associated resources.

+ 0 - gives resource URI only. Omitting the parameter has the same effect.
+ 1 - gives resource URI plus type and title/name from the model metadata.
+ 2 - gives resource URI plus all the model metadata for a resource.

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

### Some possible publishing strategies

Associated identifiers (UUIDs) are available after transformation in a hash of
sets for :dataset, :organisation, :person, :project, and :publication.
Organisation is only available if the granularity parameter is set to 2.

+ Transform a single resource, setting granularity to 0, 1 or 2.

+ Transform a single dataset resource, setting granularity to 0. Transform
other resources using UUIDs from the identifiers hash later, setting
granularity to 2.

+ Transform a single dataset resource, setting granularity to 0. Repeat,
combining statements together from subsequent graphs and merging subsequent sets
of identifiers. Transform other resources using UUIDs from the identifiers hash
later, setting granularity to 2.

+ Transform a single dataset resource, setting granularity to 2.
Repeat, combining statements from subsequent graphs into a larger graph.