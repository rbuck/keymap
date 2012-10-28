module Keymap

# Generic Keymap exception class.
  class KeymapError < StandardError
  end

# Raised when adapter not specified on connection (or configuration file <tt>config/database.yml</tt>
# misses adapter field).
  class AdapterNotSpecified < KeymapError
  end

# Raised when Keymap cannot find database adapter specified in <tt>config/database.yml</tt> or programmatically.
  class AdapterNotFound < KeymapError
  end

# Raised when connection to the database could not been established (for example when <tt>connection=</tt>
# is given a nil object).
  class ConnectionNotEstablished < KeymapError
  end

# The library uses this exception to distinguish a deliberate rollback from other
# exceptional situations. Normally, raising an exception will cause the
# +transaction+ method to rollback the database transaction *and* pass on the
# exception. But if you raise a Rollback exception, then the database transaction
# will be rolled back, without passing on the exception.
  class Rollback < KeymapError
  end

end