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

Control what metadata is put into the graph.

Omit - gives resource URI only.

+ :min - gives resource URI plus type and title/name from the model metadata.
+ :max - gives resource URI plus all the model metadata for a resource.

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

#### Some possible strategies

Identifiers (UUIDs) are available after transformation in a hash of sets for
:dataset, :organisation, :person, :project, and :publication. Organisation is
only available if the resource_expansion parameter has the value :max.

+ Transform a single resource, setting resource_expansion to :min.

+ Transform a single resource, omitting resource_expansion parameter. Transform
other resources using UUIDs from the identifiers hash later, setting
resource_expansion parameter to :max.

+ Transform a single resource, omitting resource_expansion parameter. Repeat,
combining statements together from subsequent graphs and merging subsequent sets
of identifiers. Transform other resources using UUIDs from the identifiers hash
later, setting resource_expansion parameter to :max.

+ Transform a single resource, setting resource_expansion parameter to :max.
Repeat, combining statements together from subsequent graphs into a larger graph.