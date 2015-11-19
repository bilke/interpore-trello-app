#require "maruku"

class Meta
  attr_reader :cards
  def initialize list
    @cards = list.cards
  end

  def imprint
    if card = find_card("Imprint")
      md_to_html(card.desc)
    end
  end

  def editors
    if card = find_card("Editors")
      md_to_html(card.desc)
    end
  end

  def published_at
    cards.first.name
  end

  def publish_date_string
    date = Date.parse(published_at)
    date.strftime("#{date.day.ordinalize} %B %Y")
  end

  private

  def find_card name
    cards.find { |card| card.name == name }
  end

  def md_to_html text
    Maruku.new("\n" + text).to_html
  end
end
