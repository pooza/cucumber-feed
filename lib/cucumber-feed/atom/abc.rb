require 'cucumber-feed/atom'

module CucumberFeed
  class AbcAtom < Atom
    def initialize
      super
      @config = Config.new
    end

    def channel_title
      return 'ABC毎日放送 プリキュア公式'
    end

    def url
      return 'https://www.asahi.co.jp/precure/'
    end

    protected
    def source
      unless @sourcce
        html = open(url) do |f|
          f.read
        end
        @source = Nokogiri::HTML.parse(html.force_encoding('utf-8'), nil, 'utf-8')
      end
      return @source
    end

    def entries
      data = []
require 'pp'
pp source.xpath('//div[@id="news"]')
      source.xpath('//ul[@class="news_list"]//li').each do |node|
pp node

        begin
          data.push({
            link: URI.parse(node.search('a').attribute('href')).to_s,
            title: node.search('a').inner_html,
            date: Time.parse(node.search('dt').inner_html),
          })
        rescue => e
          # 当面、例外が発生したら捨てる
        end
      end
      return data
    end
  end
end
