require 'trello'
require "yaml"
require "pathname"
require "fileutils"
require 'slim'
require_relative 'meta'
require_relative 'post'

config_hash = YAML::load_file("config/secret.yml")["development"]

Trello.configure do |config|
  config.developer_public_key = config_hash["trello_developer_public_key"]
  config.member_token = config_hash["trello_member_token"]
end

class Importer
  attr_reader :root_dir
  def initialize root_dir
    @root_dir = root_dir
  end

  def issues_dir
    @issues_dir ||= File.join root_dir, "source"
  end

  def next_issue_number
    Pathname.new(issues_dir)
    .children
    .select { |child| child.directory? }
    .map    { |dir| dir.basename.to_s }
    .select { |dirname| dirname.match /\A\d/ }
    .map(&:to_i).sort.last.succ.to_s
  end

  def import issue_number
    start_time = Time.now
    proc = Proc.new do

      if issue_number.nil?
        issue_number = next_issue_number

        puts "No issue number specified. Guessing you want ##{issue_number}..."
      end

      board_name = "Issue ##{issue_number}"
      board = Trello::Board.all.find { |b| b.name == board_name }

      if board.nil?
        abort "Unable to find board named: #{board_name}"
      end

      lists = board.lists
      meta = Meta.new lists.shift

      issue_dir = File.join issues_dir, issue_number
      FileUtils.mkdir_p issue_dir
      issue_file = File.join issue_dir, "index.html"

      output = File.open issue_file, "w"
      output.puts Tilt.new("templates/index.html.slim").render(self,
        issue_number: issue_number,
        meta: meta,
        lists: lists)
    end
    proc.call

    total_time = (Time.now - start_time).round 2
    puts "Generated issue ##{issue_number} in #{total_time} seconds."
  end
end
