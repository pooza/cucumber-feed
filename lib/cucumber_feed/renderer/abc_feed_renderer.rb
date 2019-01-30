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
      return 'https://www.asahi.co.jp/precure/twinkle/news/'
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
        source.xpath('//ul[@class="listbox"]//a').each do |node|
          @entries.push({
            link: parse_url(node.attribute('href')).to_s,
            title: node.search('dd').inner_text.gsub(/\s+/, ' ').strip,
            date: Time.parse(node.search('dt').inner_text),
            image: node.search('img').attribute('src').value,
          })
        end
      end
      return @entries
    end
  end
end
