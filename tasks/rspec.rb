require 'rubygems'
require 'rake'

GEM_ROOT ||= File.expand_path(File.join(File.dirname(__FILE__), ".."))

begin

  require 'rspec/core/rake_task'

  task :default => :spec

  desc "Run all specs in spec directory"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ['--options', "\"#{GEM_ROOT}/.rspec\""]
    t.pattern = FileList['spec/**/*_spec.rb']
  end

  desc "Run all functional specs (in functional/ directory)"
  RSpec::Core::RakeTask.new(:functional) do |t|
    t.rspec_opts = ['--options', "\"#{GEM_ROOT}/spec/spec.opts\""]
    t.pattern = FileList['spec/functional/**/*_spec.rb']
  end

  desc "Run the rspec tests with activesupport loaded"
  RSpec::Core::RakeTask.new(:spec_activesupport) do |t|
    t.rspec_opts = ['--options', "\"#{GEM_ROOT}/.rspec\"", "--require active_support/core_ext"]
    t.pattern = FileList['spec/unit/**/*_spec.rb']
  end

  namespace :spec do
    #desc "Run all specs in spec directory with RCov"
    #RSpec::Core::RakeTask.new(:cov) do |t|
    #  require 'simplecov'
    #  SimpleCov.start do
    #    add_group 'Libraries', 'lib'
    #  end
    #end

    desc "Print Specdoc for all specs"
    RSpec::Core::RakeTask.new(:doc) do |t|
      t.rspec_opts = %w(--format specdoc --dry-run)
      t.pattern = FileList['spec/**/*_spec.rb']
    end

    [:unit].each do |sub|
      desc "Run the specs under spec/#{sub}"
      RSpec::Core::RakeTask.new(sub) do |t|
        t.rspec_opts = ['--options', "\"#{GEM_ROOT}/spec/spec.opts\""]
        t.pattern = FileList["spec/#{sub}/**/*_spec.rb"]
      end
    end
  end

rescue LoadError
  STDERR.puts "\n*** RSpec not available. (sudo) gem install rspec to run unit tests. ***\n\n"
end