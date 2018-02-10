require 'cucumber-feed/atom'
require 'nokogiri'
require 'time'

module CucumberFeed
  class GardenAtom < Atom
    def initialize
      super
      @config = Config.new
    end

    def channel_title
      return 'プリキュアガーデン'
    end

    def url
      return 'http://www.toei-anim.co.jp/ptr/precure/'
    end

    protected
    def source
      unless @sourcce
        html = open(source_url) do |f|
          f.read
        end
        @source = Nokogiri::HTML.parse(html.force_encoding('utf-8'), nil, 'utf-8')
      end
      return @source
    end

    def entries
      data = []
      path = '//div[@class="boxMain box--mainTopics box--top"]//a[@class="card__box"]'
      source.xpath(path).each do |node|
        begin
          data.push({
            link: URI.parse(url + node.attribute('href')).to_s,
            title: node.search('p[@class="card__text"]').inner_html,
            date: Time.parse(node.search('p[@class="card__date card__icon--new"]').inner_html),
          })
        rescue => e
          # 当面、例外が発生したら捨てる
        end
      end
      return data
    end
  end
end
