#!/usr/bin/env rake

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rdoc/task'
require 'bundler'
require 'bundler/gem_tasks'

require File.expand_path(File.dirname(__FILE__)) + "/spec/support/config"
require File.expand_path(File.dirname(__FILE__)) + "/tasks/rspec"

Bundler::GemHelper.install_tasks

load 'keymap.gemspec'

Dir['tasks/**/*.rb'].each { |file| load file }

GEM_NAME = "keymap"
GEM_VERSION = Keymap::VERSION

CLEAN.include('pkg')

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
    task(:env) { ENV['KEYMAPPCONN'] = adapter }
  end

  # Make sure the adapter test evaluates the env setting task
  task "test_#{adapter}" => "#{adapter}:env"
end

desc "Prints lines of code metrics"
task :lines do
  lines, codelines, total_lines, total_codelines = 0, 0, 0, 0

  FileList["lib/keymap/**/*.rb"].each { |file_name|
    next if file_name =~ /vendor/
    f = File.open(file_name)

    while (line = f.gets)
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
    puts "L: #{sprintf("%4d", lines)}, LOC #{sprintf("%4d", codelines)} | #{file_name}"

    total_lines += lines
    total_codelines += codelines

    lines, codelines = 0, 0
  }

  puts "Total: Lines #{total_lines}, LOC #{total_codelines}"
end
