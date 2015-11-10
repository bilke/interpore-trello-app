require 'trello'
require 'yaml'

if File.exist?("config/secret.yml")
  config_hash = YAML::load_file("config/secret.yml")["development"]
else
  config_hash = nil
end

Trello.configure do |config|
  if config_hash.nil?
    config.developer_public_key = ENV["trello_developer_public_key"]
    config.member_token = ENV["trello_member_token"]
  else
    config.developer_public_key = config_hash["trello_developer_public_key"]
    config.member_token = config_hash["trello_member_token"]
  end
end
