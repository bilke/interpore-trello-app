require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'slim'
require_relative 'init'
require_relative 'importer'
require_relative 'post'

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
  card_id = params['card-id']
  card = Trello::Card.find(card_id)
  if card
    post = Post.new(card)
    slim :entry, locals: { :post => post }
  end
end
