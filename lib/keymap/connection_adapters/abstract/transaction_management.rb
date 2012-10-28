require 'keymap/errors'

module Keymap
  module ConnectionAdapters # :nodoc:
    module TransactionManagement

      # Runs the given block in a database transaction, and returns the result
      # of the block.
      def transaction(options = {})
        transaction_open = false
        @_current_transaction_records ||= []
        begin
          if block_given?
            begin_db_transaction
            transaction_open = true
            @_current_transaction_records.push([])
            yield
          end
        rescue Exception => database_transaction_rollback
          if transaction_open && !outside_transaction?
            transaction_open = false
            rollback_db_transaction
          end
          raise unless database_transaction_rollback.is_a?(Rollback)
        end
      ensure
        if transaction_open
          begin
            commit_db_transaction
          rescue Exception => database_transaction_rollback
            rollback_db_transaction
            raise
          end
        end
      end

    end
  end
end