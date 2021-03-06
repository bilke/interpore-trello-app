require "maruku"

class Post
  attr_reader :card
  def initialize card
    @card = card
  end

  def body
    @body ||= begin
      if card.desc
        Maruku.new("\n" + card.desc).to_html
      else
        puts "No text given in card #{card.name}"
      end
    end
  end

  def draft?
    card.desc.empty? || card.labels.any? { |label| label.name == "Draft" }
  end

  def link
    @link ||= if attached_link
                attached_link.url
              else
                card.desc.lines.first.chomp
              end
  end

  def sponsored?
    card.labels.any? { |label| label.name == "Sponsored" }
  end

  def title
    card.name
  end

  private

  def attached_link
    @attached_link ||= card.attachments.first
  end

end
