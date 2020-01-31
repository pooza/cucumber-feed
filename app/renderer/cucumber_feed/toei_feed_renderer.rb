require 'nokogiri'
require 'time'

module CucumberFeed
  class ToeiFeedRenderer < FeedRenderer
    def channel_title
      return '東映アニメーション プリキュア公式'
    end

    def url
      return 'http://www.toei-anim.co.jp/tv/precure/'
    end

    private

    def source
      @source ||= Nokogiri::HTML.parse(
        @http.get(source_url).to_s.force_encoding('utf-8'),
        nil,
        'utf-8',
      )
      return @source
    end

    def entries
      unless @entries
        @entries = []
        source.xpath('//ul[@class="m-list-topics"]//a').each do |node|
          @entries.push({
            link: parse_url(node.attribute('href')).to_s,
            title: node.search('dd').inner_text,
            date: Time.parse(node.search('dt').inner_text),
            image: node.search('img').attribute('src').value,
          })
        end
      end
      return @entries
    end
  end
end
