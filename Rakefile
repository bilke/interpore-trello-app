require 'rubygems'
require 'bundler'
require './lib/importer'

Bundler.setup

desc "Import from Trello board"
task :import do
  Importer.new(File.dirname(__FILE__)).import ENV["ISSUE"]
end
