require 'keymap/connection_adapters/abstract_adapter'
require 'redis'

module Keymap

  class Base
    def self.redis_connection(config)
      config = config.symbolize_keys
      config[:port] ||= 6379
      ConnectionAdapters::RedisAdapter.new(nil, nil, config)
    end
  end

  module ConnectionAdapters

    class RedisAdapter < AbstractAdapter

      attr_reader :config

      def initialize(connection, pool, config)
        super(nil)
        @config = config
        reconnect!
      end

      def adapter_name
        'redis'
      end

      def active?
        return false unless @connection
        @connection.ping == "PONG"
      end

      def reconnect!
        disconnect!
        connect
        super
      end

      alias :reset! :reconnect!

      # Disconnects from the database if already connected.
      # Otherwise, this method does nothing.
      def disconnect!
        super
        unless @connection.nil?
          @connection.quit
          @connection = nil
        end
      end

      private

      def connect
        @connection = Redis.new(config)
      end

      public

      def begin_db_transaction
        raw_connection.multi
      end

      def commit_db_transaction
        raw_connection.exec
      end

      def rollback_db_transaction
        raw_connection.discard
      end

      # Retrieves the hash whose name is identified by key.
      def hash (key)
        coll = KeyStoreHash.new
        coll.connection = raw_connection
        coll.key = key
        coll
        #
        # Perhaps there is a more experienced ruby developer who could help with this.
        # I'd rather do the following but could not figure out how to get it to work:
        #
        #def create_getter(connection, key)
        #  lambda { |field| connection.hget key, field }
        #end
        #
        #def create_setter(connection, key)
        #  lambda { |field, value| connection.hset key, field, value }
        #end
        #
        #coll.class.send :define_method, "[]", create_getter(raw_connection, key)
        #coll.class.send :define_method, "[]=", create_setter(raw_connection, key)
        #coll
      end
    end

    private

    class KeyStoreHash < Hash

      attr_accessor :connection, :key

      def [] (field)
        connection.hget key, field
      end

      def []=(field, value)
        connection.hset key, field, value
      end
    end

  end
end
