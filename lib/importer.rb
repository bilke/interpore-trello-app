require "pathname"
require "fileutils"
require 'slim'
require 'slim/include'
require_relative 'init'
require_relative 'meta'
require_relative 'post'

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
      board = Trello::Board.all.find { |b| b.name == board_name && b.closed == false }

      if board.nil?
        abort "Unable to find board named: #{board_name}"
      end

      # p board.find_card("56409d79540c507245cbe9ae")

      if not board.has_lists?
        p board
        abort "Board #{board_name} has no lists"
      end

      @lists = board.lists
      @meta = Meta.new lists.shift

      @tocs = Array.new

      for list in @lists
        for card in list.cards
          toc = card.labels.find { |label| label.name == "TOC" }
          @tocs.push(card) if toc
        end
      end
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
                                                             lists: @lists,
                                                             tocs: @tocs)
    total_time = (Time.now - start_time).round 2
    puts "Wrote issue ##{issue_number} to file #{issue_file} in #{total_time} seconds."
  end
end
