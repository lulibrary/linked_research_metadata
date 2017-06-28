# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "linked_research_metadata/version"

Gem::Specification.new do |spec|
  spec.name          = "linked_research_metadata"
  spec.version       = LinkedResearchMetadata::VERSION
  spec.authors       = ["Adrian Albin-Clark"]
  spec.email         = ["a.albin-clark@lancaster.ac.uk"]

  spec.summary       = %q{Metadata extraction from the Pure Research Information System and transformation of the metadata into RDF.}
  spec.homepage      = "https://github.com/lulibrary/linked_research_metadata"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  #spec.bindir        = "exe"
  #spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.3'

  spec.add_runtime_dependency "puree", "~> 1.3"
  spec.add_runtime_dependency "linkeddata", "~> 2.2"

end
