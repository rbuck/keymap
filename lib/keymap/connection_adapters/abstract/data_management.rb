module Keymap
  module ConnectionAdapters
    module DataManagement #:nodoc:

      def delete(key)
        false
      end

      def hash (key)
        nil
      end

      def list (key)
        nil
      end

    end
  end
end