# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keymap/version'

Gem::Specification.new do |spec|
  spec.name          = "keymap"
  spec.version       = Keymap::VERSION
  spec.authors       = ['Robert Buck']
  spec.email         = 'buck.robert.j@gmail.com'
  spec.description   = %q{ActiveRecord like Key-Value Store API for Ruby}
  spec.summary       = %q{Abstracts choosing a key-value store implementation, and provides a common API.}
  spec.homepage      = 'https://github.com/rbuck/keymap'
  spec.date          = '2012-10-28'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(tasks|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "erubis", "~> 2.7.0"
  spec.add_dependency "redis", "~> 3.0.2"
  spec.add_dependency "activesupport", "~> 3.2.8"

  %w(rake rdoc simplecov).each { |gem| spec.add_development_dependency gem }
  %w(rspec rspec-core rspec-expectations rspec-mocks).each { |gem| spec.add_development_dependency gem, "~> 2.11.0" }
end
