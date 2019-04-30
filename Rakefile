require 'rubygems'
require 'bundler/setup'

desc 'Default: run specs'
task default: :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

Bundler::GemHelper.install_tasks
