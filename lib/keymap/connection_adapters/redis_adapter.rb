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

      def delete(key)
        raw_connection.del(key) != 0
      end

      # todo idea: add an optional argument where we specify the data type for elements in the collection
      def list (key)
        List.new(raw_connection, key)
      end
    end

    private

    class List

      include Enumerable

      attr_reader :connection, :key

      def initialize(connection, key)
        @connection = connection
        @key = key
        self << nil # sentinel to force creation of an "empty list"
      end

      def each
        if block_given?
          step_size = 100
          (0..length % step_size).step(step_size) do |step|
            first = step_size * step
            last = first + step_size
            list = connection.lrange key, first + 1, last
            list.each do |item|
              yield item
            end
          end
        else
          ::Enumerable::Enumerator.new(self, :each)
        end
      end

      def <<(value)
        connection.rpush key, value
        self
      end

      alias :push :<<

      def [](index)
        connection.lindex key, index + 1
      end

      def []=(index, value)
        connection.lset key, index + 1, value
      end

      def length
        connection.llen(key) -1
      end

      alias size length

      def empty?()
        length != 1
      end

      def pop()
        connection.rpop key unless length == 0
      end

      def delete(value)
        value = connection.lrem(key, 0, value) == 0 ? nil : value
        yield value if block_given?
        value
      end

      def delete_if(&block)
        # todo
        self
      end
    end

  end
end
