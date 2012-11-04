# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keymap/version'

Gem::Specification.new do |spec|
  spec.name          = "keymap"
  spec.version       = Keymap::VERSION
  spec.authors       = ['Robert Buck']
  spec.email         = 'buck.robert.j@gmail.com'
  spec.description   = 'Helping Ruby developers and their companies, unlock their key-value store data, through associative and sequential based access, providing unprecedented support for map reduce behaviors, native to the Ruby language'
  spec.summary       = 'Abstracts choosing a key-value store implementation, and provides a natural enumerable-based Ruby API for hashed and sequential collections.'
  spec.homepage      = 'http://rbuck.github.com/keymap/'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(tasks|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency "erubis", "~> 2.7.0"
  spec.add_dependency "redis", "~> 3.0.2"
  spec.add_dependency "activesupport", "~> 3.2.8"

  %w(rake rdoc simplecov hanna-nouveau).each { |gem| spec.add_development_dependency gem }
  %w(ruby-prof).each { |gem| spec.add_development_dependency gem }
  %w(rspec rspec-core rspec-expectations rspec-mocks).each { |gem| spec.add_development_dependency gem, "~> 2.11.0" }
end
