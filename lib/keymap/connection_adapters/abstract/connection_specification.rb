require 'uri'

module Keymap
  class Base
    class ConnectionSpecification #:nodoc:
      attr_reader :config, :adapter_method

      def initialize (config, adapter_method)
        @config, @adapter_method = config, adapter_method
      end

      ##
      # Builds a ConnectionSpecification from user input
      class Resolver # :nodoc:

        attr_reader :config, :configurations

        def initialize(config, configurations)
          @config = config
          @configurations = configurations
        end

        def spec
          case config
            when nil
              raise AdapterNotSpecified unless defined?(Keymap.env)
              resolve_string_connection Keymap.env
            when Symbol, String
              resolve_string_connection config.to_s
            when Hash
              resolve_hash_connection config
            else
              # type code here
          end
        end

        private

        def resolve_string_connection(spec) # :nodoc:
          hash = configurations.fetch(spec) do |k|
            connection_url_to_hash(k)
          end

          raise(AdapterNotSpecified, "#{spec} database is not configured") unless hash

          resolve_hash_connection hash
        end

        def resolve_hash_connection(spec) # :nodoc:
          spec = spec.symbolize_keys

          raise(AdapterNotSpecified, "database configuration does not specify adapter") unless spec.key?(:adapter)

          begin
            require "keymap/connection_adapters/#{spec[:adapter]}_adapter"
          rescue LoadError => e
            raise LoadError, "Please install the #{spec[:adapter]} adapter: `gem install keymap-#{spec[:adapter]}-adapter` (#{e.message})", e.backtrace
          end

          adapter_method = "#{spec[:adapter]}_connection"

          ConnectionSpecification.new(spec, adapter_method)
        end

        def connection_url_to_hash(url) # :nodoc:
          config = URI.parse url
          adapter = config.scheme
          spec = {:adapter => adapter,
                  :username => config.user,
                  :password => config.password,
                  :port => config.port,
                  :database => config.path.sub(%r{^/}, ""),
                  :host => config.host}
          spec.reject! { |_, value| !value }
          if config.query
            options = Hash[config.query.split("&").map { |pair| pair.split("=") }].symbolize_keys
            spec.merge!(options)
          end
          spec
        end

      end
    end

    ##
    # :singleton-method:
    # The connection handler
    class_attribute :connection_handler, :instance_writer => false
    self.connection_handler = Keymap::ConnectionAdapters::ConnectionHandler.new

    def connection
      self.class.connection
    end

    def self.establish_connection(spec = ENV["DATABASE_URL"])
      resolver = Keymap::Base::ConnectionSpecification::Resolver.new spec, configurations
      spec = resolver.spec

      unless respond_to?(spec.adapter_method)
        raise AdapterNotFound, "database configuration specifies nonexistent #{spec.config[:adapter]} adapter"
      end

      remove_connection
      connection_handler.establish_connection name, spec
    end

    class << self
      # Returns the connection currently associated with the class. This can
      # also be used to "borrow" the connection to do database work unrelated
      # to any of the specific Active Records.
      def connection
        retrieve_connection
      end

      def connection_id
        Thread.current['Keymap::Base.connection_id']
      end

      def connection_id=(connection_id)
        Thread.current['Keymap::Base.connection_id'] = connection_id
      end

      # Returns the configuration of the associated connection as a hash:
      #
      #  Keymap::Base.connection_config
      #  # => {:pool=>5, :timeout=>5000, :adapter=>"redis"}
      #
      # Please use only for reading.
      def connection_config
        connection_pool.spec.config
      end

      def connection_pool
        connection_handler.retrieve_connection_pool(self) or raise ConnectionNotEstablished
      end

      def retrieve_connection
        connection_handler.retrieve_connection(self)
      end

      # Returns true if Keymap is connected.
      def connected?
        connection_handler.connected?(self)
      end

      def remove_connection(klass = self)
        connection_handler.remove_connection(klass)
      end

      def clear_active_connections!
        connection_handler.clear_active_connections!
      end

      delegate :clear_reloadable_connections!,
               :clear_all_connections!, :verify_active_connections!, :to => :connection_handler
    end

  end
end