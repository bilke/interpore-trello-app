require 'rubygems'
require 'bundler'
require './lib/importer'

Bundler.setup

desc "Import from Trello board"
task :import do
  importer = Importer.new(File.dirname(__FILE__), ENV["ISSUE"])
  importer.import
  importer.write
end
