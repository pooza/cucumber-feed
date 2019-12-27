require 'nokogiri'
require 'time'

module CucumberFeed
  class MiracleLeapFeedRenderer < FeedRenderer
    def channel_title
      return '映画プリキュアミラクルリープ　みんなとの不思議な1日 公式'
    end

    def url
      return 'https://spring.precure-movie.com/pc/'
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
        source.css('#divRss .titleWrap').each do |node|
          @entries.push({
            link: parse_url(node.search('a').attribute('href')).to_s,
            title: node.search('a').inner_text,
            date: Time.parse(node.inner_text),
          })
        end
      end
      return @entries
    end
  end
end
