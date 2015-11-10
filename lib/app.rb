require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'slim'
require_relative 'importer'

set :views, settings.root + '/../templates'

get '/' do
  slim :index
end

get '/generate' do
  issue = params['issue']
  importer = Importer.new(File.dirname(__FILE__), issue)
  importer.import
  slim :newsletter, scope: importer
end

get '/generate-card' do
  card = params['card-id']
  # TODO
  # importer = Importer.new(File.dirname(__FILE__), issue)
  # importer.import
  # slim :newsletter, scope: importer
end
