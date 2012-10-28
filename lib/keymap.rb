require 'active_support'
require 'keymap/version'

module Keymap

  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :KeymapError, 'keymap/errors'
    autoload :ConnectionNotEstablished, 'keymap/errors'
    autoload :ConnectionAdapters, 'keymap/connection_adapters/abstract_adapter'
    autoload :Base
  end

  module ConnectionAdapters
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :AbstractAdapter
      autoload :ConnectionManagement, 'keymap/connection_adapters/abstract/connection_pool'
    end
  end

  def env
    @_env ||= ActiveSupport::StringInquirer.new(ENV["KEYMAP_ENV"] || ENV["KEYMAP_ENV"] || "development")
  end

  def env=(environment)
    @_env = ActiveSupport::StringInquirer.new(environment)
  end

end
