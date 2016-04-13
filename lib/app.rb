require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'slim'
require_relative 'init'
require_relative 'importer'
require_relative 'post'

set :views, settings.root + '/../templates'
set :public_folder, settings.root + '/../styles'

get '/' do
  slim :index
end

get '/generate' do
  issue = params['issue']
  importer = Importer.new(File.dirname(__FILE__), issue)
  importer.import
  slim :newsletter, scope: importer
end

get '/generate-html' do
  issue = params['issue']
  importer = Importer.new(File.dirname(__FILE__), issue)
  importer.import
  slim :newsletter_partial, scope: importer, :content_type => :txt
end

get '/generate-card' do
  card_id = params['card-id']
  card = Trello::Card.find(card_id)
  if card
    post = Post.new(card)
    slim :entry_web, locals: { :post => post }
  end
end

get '/generate-card-html' do
  card_id = params['card-id']
  card = Trello::Card.find(card_id)
  if card
    post = Post.new(card)
    slim :entry_web, locals: { :post => post }, :content_type => :txt
  end
end

get '/generate-multiple-issues-preview' do
  appendedHTML = ''
  list = params['issue-list']
  issueArray = list.split(' ')
  issueArray.each do |issue|
    importer = Importer.new(File.dirname(__FILE__), issue)
    importer.import
    html = Slim::Template.new('templates/newsletter_partial.slim').render(importer)
    appendedHTML << html
  end
  # body = appendedHTML
  slim :basic, locals: { :body => appendedHTML }
end
