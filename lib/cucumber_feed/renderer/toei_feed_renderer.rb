require 'nokogiri'
require 'time'
require 'httparty'

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
        HTTParty.get(source_url, {headers: headers}).to_s.force_encoding('utf-8'),
        nil,
        'utf-8',
      )
      return @source
    end

    def entries
      unless @entries
        @entries = []
        source.xpath('//div[@class="u-list-news"]//a').each do |node|
          @entries.push({
            link: parse_url(node.attribute('href')).to_s,
            title: node.search('p').inner_text.gsub(/\s+/, ' ').strip,
            date: Time.parse(node.search('p[@class="data-date"]').inner_text),
            image: node.search('img').attribute('src').value,
          })
        end
      end
      return @entries
    end
  end
end
