# frozen_string_literal: true

require_relative 'lib/legion/extensions/reality_testing/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-reality-testing'
  spec.version       = Legion::Extensions::RealityTesting::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Reality Testing'
  spec.description   = 'Belief validation, evidence accumulation, and reality coherence for brain-modeled agentic AI'
  spec.homepage      = 'https://github.com/LegionIO/lex-reality-testing'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-reality-testing'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-reality-testing'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-reality-testing'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-reality-testing/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-reality-testing.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
end
