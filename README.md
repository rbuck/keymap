# Keymap

A NoSQL database abstraction similar in design to ActiveRecord but solely
focussed on NoSQL databases. These are the goals for this project:

1. Provide a simple abstraction layer over NoSQL databases, allowing easy
   migration from one to another without having to rewrite application code.

2. Provide a natural Ruby integration with NoSQL database, allowing direct
   use of Enumerable operations on returned values (implying returned values
   are always lists or hashes, or are manipulated to be represented in these
   forms).

[![Continuous Integration status](https://secure.travis-ci.org/rbuck/keymap.png)](http://travis-ci.org/rbuck/keymap)

## Installation

Add this line to your application's Gemfile:

    gem 'keymap'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keymap

## Usage

TBD

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Writing New Adapters

1. Create a new adapter file named #{database_name}_adapter.rb, placing it
   in the connection adapters directory.
2. Add an entry to the list of supported databases in the Rakefile.
3. Add test configuration entries in the spec/support/config.yml file.
4. Verify all tests pass when the KEYMAP_CONN=#{database_name} environment
   variable is set.
