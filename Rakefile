#!/usr/bin/env rake

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'

require 'bundler'
require 'bundler/gem_tasks'

require File.expand_path(File.dirname(__FILE__)) + "/spec/support/config"
require File.expand_path(File.dirname(__FILE__)) + "/tasks/rspec"

Bundler::GemHelper.install_tasks

load 'keymap.gemspec'

GEM_NAME = "keymap"
GEM_VERSION = Keymap::VERSION

CLEAN.include('doc/ri')
CLEAN.include('doc/site')
CLEAN.include('pkg')

Dir['tasks/**/*.rb'].each { |file| load file }

task :default => :spec

desc "Push gem packages"
task :push => :build do
  sh "gem push #{GEM_NAME}*.gem"
end

desc "Installs the gem"
task :install => :build do
  sh %{gem install pkg/#{GEM_NAME}-#{GEM_VERSION} --no-rdoc --no-ri}
end

task :uninstall do
  sh %{gem uninstall #{GEM_NAME} -x -v #{GEM_VERSION}}
end

desc "Tags git with the latest gem version"
task :tag do
  sh %{git tag v#{GEM_VERSION}}
end

desc "Release version #{Keymap::VERSION}"
task :release => [:tag, :push]

desc "Provides tasks for each adapter type, e.g. test_redis"
%w( redis ).each do |adapter|
  Rake::TestTask.new("test_#{adapter}") { |t|
    adapter_short = adapter[/^[a-z0-9]+/]
    t.libs << 'test'
    t.test_files = (Dir.glob("spec/cases/**/*_spec.rb").reject {
        |x| x =~ /\/adapters\//
    } + Dir.glob("spec/functional/adapters/#{adapter_short}/**/*_spec.rb")).sort

    t.verbose = true
    t.warning = true
  }

  # Set the connection environment for the adapter
  namespace adapter do
    task :test => "test_#{adapter}"
    task(:env) { ENV['KEYCONN'] = adapter }
  end

  # Make sure the adapter test evaluates the env setting task
  task "test_#{adapter}" => "#{adapter}:env"
end

namespace :redis do
  task :start_server do
    config = KeymapTest.config['connections']['redis']
    puts %x( echo "daemonize yes\nport #{config['test']['port']}\ndir #{File.dirname(__FILE__)}" | redis-server - )
  end

  task :stop_server do
    config = KeymapTest.config['connections']['redis']
    puts %x( redis-cli -p #{config['test']['port']} shutdown )
  end

  task :restart_server => [:stop_server, :start_server]
end
