require 'nokogiri'
require 'time'

module CucumberFeed
  class HealingoodMovieFeedRenderer < FeedRenderer
    def channel_title
      return '映画 ヒーリングっど♥プリキュア ゆめのまちキュン！っと GOGO！大変身！！ 公式'
    end

    def url
      return 'https://2021spring.precure-movie.com/'
    end

    def source_url
      return 'https://2021spring.precure-movie.com/pc/news/'
    end

    def parse_url(href)
      url = Ginseng::URI.parse(href)
      unless url.absolute?
        local_url = url.clone
        url = Ginseng::URI.parse(self.url)
        if href.to_s.start_with?('/')
          url.path = local_url.path
        else
          url.path = File.expand_path(local_url.path, Ginseng::URI.parse(source_url).path)
        end
        url.query = local_url.query
        url.fragment = local_url.fragment
      end
      return url
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
        source.xpath('//ul[@class="kiji-list-group"]//a').each do |node|
          next unless node.attribute('href')
          @entries.push({
            link: parse_url(node.attribute('href')).to_s,
            title: node.css('.text').inner_text,
            date: Time.parse(node.css('.kiji-date').inner_text),
          })
        rescue => e
          @logger.error(class: self.class.to_s, error: e.message)
        end
      end
      return @entries
    end
  end
end
