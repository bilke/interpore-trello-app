require 'trello'
require "yaml"
require "pathname"
require "fileutils"
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
    issue_file = File.join issue_dir, "index.html.erb"

    template = File.open issue_file, "w"

    template.puts <<-DOC.gsub(/^ {4}/, '')
    <%
      @title = "Issue ##{issue_number}"
    @published_at = "#{meta.published_at}"
    %>
    <% content_for :preview_text, @preview_text %>
    <% content_for :title, @title %>
        DOC

    lists.each do |list|
      next if list.cards.empty?

      template.puts "\n<% content_block do %>\n"
      template.puts "\n  <h3>#{list.name}</h3>\n\n"

      list.cards.each do |card|
        post = Post.new card

        if card == list.cards.last
          template.puts "  <div class='list-item last-of-type'>"
        else
          template.puts "  <div class='list-item'>"
        end

        if post.draft?
          next
        end

        if post.sponsored?
          template.puts "    <h5>Sponsored</h5>"
        end

        if post.link !~ URI::regexp
          puts "WARNING: #{post.title} does not have a valid link!"
          template.puts "    <h5 class='item--error'>Whoops</h5>"
        end

        template.puts "    <h2><a href='#{post.link}'>#{post.title}</a></h2>"
        template.puts "    #{post.body}"
        template.puts "  </div>\n\n"
      end

      template.puts "<% end %>\n"
    end

    template.close

    total_time = (Time.now - start_time).round 2
    puts "Generated issue ##{issue_number} in #{total_time} seconds."
  end
end
