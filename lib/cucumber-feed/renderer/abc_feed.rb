require 'cucumber-feed/feed_renderer'
require 'httparty'

module CucumberFeed
  class AbcFeedRenderer < FeedRenderer
    def channel_title
      return 'ABC毎日放送 プリキュア公式'
    end

    def url
      return 'https://www.asahi.co.jp/precure/'
    end

    def source_url
      return 'https://www.asahi.co.jp/precure/hugtto/js/inc/news.js'
    end

    protected

    def entries
      unless @entries
        @entries = []
        pattern = %r{\<li.*?\>.*?\<dt\>(.*?)\</dt\>.*?href=\"(.*?)\".*?\>(.*?)\</a\>.*?\</li\>}m
        HTTParty.get(source_url, {headers: headers}).to_s.scan(pattern).each do |matches|
          @entries.push({
            date: Time.parse(matches[0]),
            title: sanitize(matches[2].force_encoding('utf-8')),
            link: parse_url(matches[1]).to_s,
          })
        end
      end
      return @entries
    end
  end
end
