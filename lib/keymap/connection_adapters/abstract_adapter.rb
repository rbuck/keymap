require 'monitor'
require 'active_support/callbacks'
require 'active_support/dependencies/autoload'

module Keymap

  module ConnectionAdapters # :nodoc:

    extend ActiveSupport::Autoload

    autoload_under 'abstract' do
      autoload :ConnectionPool
      autoload :ConnectionHandler, 'keymap/connection_adapters/abstract/connection_pool'
      autoload :ConnectionManagement, 'keymap/connection_adapters/abstract/connection_pool'
      autoload :ConnectionSpecification
      autoload :TransactionManagement
      autoload :DataManagement
    end

    class AbstractAdapter

      include ActiveSupport::Callbacks
      include TransactionManagement
      include DataManagement
      include MonitorMixin

      define_callbacks :checkout, :checkin
      attr_accessor :pool
      attr_reader :last_use, :in_use, :logger
      alias :in_use? :in_use

      def initialize(connection, logger = nil, pool = nil) #:nodoc:
        super()

        @active = nil
        @connection = connection
        @logger = logger
        @pool = pool

        @in_use = false
        @last_use = false
      end

      def lease
        synchronize do
          unless in_use
            @in_use = true
            @last_use = Time.now
          end
        end
      end

      def expire
        @in_use = false
      end

      # Returns the human-readable name of the adapter. Use mixed case - one
      # can always use downcase if needed.
      def adapter_name
        'Abstract'
      end

      # CONNECTION MANAGEMENT ====================================

      # Checks whether the connection to the database is still active. This includes
      # checking whether the kv-store is actually capable of responding, i.e. whether
      # the connection isn't stale.
      def active?
        @active
      end

      # Disconnects from the database if already connected, and establishes a
      # new connection with the database.
      def reconnect!
        @active = true
      end

      # Disconnects from the kv-store if already connected. Otherwise, this
      # method does nothing.
      def disconnect!
        @active = false
      end

      # Reset the state of this connection, directing the kv-store to clear
      # transactions and other connection-related server-side state. Usually a
      # implementation-dependent operation.
      #
      # The default implementation does nothing; the implementation should be
      # overridden by concrete adapters.
      def reset!
        # this should be overridden by concrete adapters
      end

      ###
      # Clear any caching the kv-store adapter may be doing. This is kv-store
      # specific.
      def clear_cache!
        # this should be overridden by concrete adapters
      end

      # Returns true if its required to reload the connection between requests for development mode.
      def requires_reloading?
        false
      end

      # Checks whether the connection to the kv-store is still active (i.e. not stale).
      # This is done under the hood by calling <tt>active?</tt>. If the connection
      # is no longer active, then this method will reconnect to the kv-store.
      def verify!
        reconnect! unless active?
      end

      # Provides access to the underlying kv-store driver for this adapter. For
      # example, this method returns a Redis object in case of RedisAdapter.
      #
      # This is useful for when you need to call a proprietary method.
      def raw_connection
        @connection
      end

      # Begins the transaction (and turns off auto-committing).
      def begin_db_transaction()
      end

      # Commits the transaction (and turns on auto-committing).
      def commit_db_transaction()
      end

      # Rolls back the transaction (and turns on auto-committing). Must be
      # done if the transaction block raises an exception or returns false.
      def rollback_db_transaction()
      end

      # Check the connection back in to the connection pool
      def close
        pool.checkin self
      end
    end

  end
end