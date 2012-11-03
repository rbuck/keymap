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

      def delete(id)
        raw_connection.del(id) != 0
      end

      def hash (id)
        RedisHash.new(raw_connection, id)
      end

      def list (id)
        # todo idea: add an optional argument where we specify the data type for elements in the collection
        RedisList.new(raw_connection, id)
      end
    end

    private

    class RedisHash

      include Enumerable

      attr_reader :connection, :id, :sentinel

      # n.b. nil gets represented as an empty string by redis, so the two are
      # in effect identical keys.
      def initialize(connection, id, sentinel=nil)
        @connection = connection
        @id = id
        @sentinel = sentinel
        self[sentinel] = sentinel
      end

      def empty?
        connection.hlen id == 1
      end

      def [](key)
        connection.hget id, key
      end

      def []=(key, value)
        connection.hset id, key, value
      end

      def each
        if block_given?
          hash_keys.each { |key| yield [key, self[key]] unless key == sentinel }
        else
          ::Enumerable::Enumerator.new(self, :each)
        end
      end

      def each_pair
        if block_given?
          hash_keys.each { |key| yield key, self[key] unless key == sentinel }
        else
          ::Enumerable::Enumerator.new(self, :each_pair)
        end
      end

      def each_value
        if block_given?
          hash_keys.each { |key| yield self[key] unless key == sentinel }
        else
          ::Enumerable::Enumerator.new(self, :each_value)
        end
      end

      def delete(key)
        value = self[key]
        connection.hdel id, key
        value
      end

      def merge!(hash)
        hash.each do |key, value|
          self[key] = value
        end
        self
      end

      alias merge merge!

      private

      def hash_keys
        keys = connection.hkeys id
        keys.delete sentinel
        keys.delete ''
        keys
      end
    end

    class RedisList

      include Enumerable

      attr_reader :connection, :id

      def initialize(connection, id, sentinel=nil)
        @connection = connection
        @id = id
        self << sentinel # sentinel to force creation of an "empty list"
      end

      def each
        if block_given?
          step_size = 100
          (0..length % step_size).step(step_size) do |step|
            first = step_size * step
            last = first + step_size
            list = connection.lrange id, first + 1, last
            list.each do |item|
              yield item
            end
          end
        else
          ::Enumerable::Enumerator.new(self, :each)
        end
      end

      def <<(value)
        connection.rpush id, value
        self
      end

      alias :push :<<

      def [](index)
        connection.lindex id, index + 1
      end

      def []=(index, value)
        connection.lset id, index + 1, value
      end

      def concat array
        array.each do |entry|
          self << entry
        end
        self
      end

      def length
        connection.llen(id) -1
      end

      alias size length

      def empty?()
        length != 1
      end

      def pop()
        connection.rpop id unless length == 0
      end

      def delete(value)
        value = connection.lrem(id, 0, value) == 0 ? nil : value
        yield value if block_given?
        value
      end

      def delete_if
        if block_given?
          each do |value|
            delete(value) if yield(value)
          end
          self
        else
          nil
        end
      end
    end

  end
end
