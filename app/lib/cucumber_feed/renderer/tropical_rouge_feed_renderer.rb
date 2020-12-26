require 'nokogiri'
require 'time'

module CucumberFeed
  class TropicalRougeFeedRenderer < FeedRenderer
    def channel_title
      return 'トロピカル～ジュ！プリキュア 公式'
    end

    def url
      return 'http://www.toei-anim.co.jp/tv/tropical-rouge_precure/'
    end

    def source_url
      return 'http://www.toei-anim.co.jp/tv/tropical-rouge_precure/news/'
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
        source.xpath('//ul[@class="m-list-topics"]//a').each do |node|
          next unless node.attribute('href')
          @entries.push({
            link: parse_url(node.attribute('href')).to_s,
            title: node.search('dd').inner_text,
            date: Time.parse(node.search('dt').inner_text),
            image: node.search('img').attribute('src').value,
          })
        rescue => e
          @logger.error(class: self.class.to_s, error: e.message)
        end
      end
      return @entries
    end
  end
end
