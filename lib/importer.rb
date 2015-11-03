require 'trello'
require "yaml"
require "pathname"
require "fileutils"
require 'slim'
require_relative 'meta'
require_relative 'post'

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

class Importer
  attr_reader :root_dir
  def initialize root_dir, issue_number
    @root_dir = root_dir
    @issue_number = issue_number
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

  attr_reader :issue_number
  attr_reader :meta
  attr_reader :lists

  def import
    start_time = Time.now
    proc = Proc.new do

      if @issue_number.nil?
        @issue_number = next_issue_number

        puts "No issue number specified. Guessing you want ##{issue_number}..."
      end

      board_name = "Issue ##{issue_number}"
      board = Trello::Board.all.find { |b| b.name == board_name }

      if board.nil?
        abort "Unable to find board named: #{board_name}"
      end

      @lists = board.lists
      @meta = Meta.new lists.shift
    end
    proc.call

    total_time = (Time.now - start_time).round 2
    puts "Downloaded issue ##{issue_number} from Trello in #{total_time} seconds."
  end

  def write
    start_time = Time.now
    issue_dir = File.join issues_dir, issue_number
    FileUtils.mkdir_p issue_dir
    issue_file = File.join issue_dir, "newsletter.html"

    output = File.open issue_file, "w"
    output.puts Tilt.new("templates/newsletter.slim").render(self,
                                                             issue_number: @issue_number,
                                                             meta: @meta,
                                                             lists: @lists)
    total_time = (Time.now - start_time).round 2
    puts "Wrote issue ##{issue_number} to file #{issue_file} in #{total_time} seconds."
  end
end
