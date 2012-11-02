require 'active_support/dependencies'
require 'active_support/descendants_tracker'

require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/module/delegation'

module Keymap

  class Base
    ##
    # :singleton-method:
    # Accepts a logger conforming to the interface of Log4r or the default Ruby 1.8+ Logger class,
    # which is then passed on to any new database connections made and which can be retrieved on both
    # a class and instance level by calling +logger+.
    cattr_accessor :logger, :instance_writer => false

    ##
    # :singleton-method:
    # Contains the database configuration - as is typically stored in config/database.yml -
    # as a Hash.
    #
    # For example, the following database.yml...
    #
    #   development:
    #     adapter: redis
    #
    #   production:
    #     adapter: redis
    #
    # ...would result in Keymap::Base.configurations to look like this:
    #
    #   {
    #      'development' => {
    #         'adapter'  => 'redis',
    #      },
    #      'production' => {
    #         'adapter'  => 'redis',
    #      }
    #   }
    cattr_accessor :configurations, :instance_writer => false
    @@configurations = {}

    public

    def initialize(attributes = nil, options = {})
      yield self if block_given?
      #run_callbacks :initialize
    end

    private

    extend ActiveSupport::DescendantsTracker

    include ActiveSupport::Callbacks

  end
end
require 'keymap/connection_adapters/abstract/connection_specification'
ActiveSupport.run_load_hooks(:keymap, Keymap::Base)
