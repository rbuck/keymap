require 'logger'

module KeymapTest
  def self.connection_name
    ENV['KEYMAP_CONN'] || config['default_connection']
  end

  def self.connection_config
    config['connections'][connection_name]
  end

  def self.connect
    Keymap::Base.logger = Logger.new("debug.log")
    Keymap::Base.configurations = connection_config
    Keymap::Base.establish_connection 'kmunit'
  end
end
