require 'yaml'
require 'erubis'
require 'fileutils'
require 'pathname'

SPEC_ROOT = File.expand_path(File.dirname(__FILE__))

module KeymapTest
  class << self
    def config
      @config ||= read_config
    end

    private

    def config_file
      Pathname.new(ENV['KEYMAP_CONFIG'] || File.join(SPEC_ROOT, 'config.yml'))
    end

    def read_config
      unless config_file.exist?
        FileUtils.cp(File.join(SPEC_ROOT, 'config.example.yml'), config_file)
      end

      erb = Erubis::Eruby.new(config_file.read)
      expand_config(YAML.parse(erb.result(binding)).transform)
    end

    def expand_config(config)
      config
    end
  end
end
