module CucumberFeed
  class AbcFeedRenderer < FeedRenderer
    def channel_title
      return 'ABC毎日放送 プリキュア公式'
    end

    def url
      return 'https://www.asahi.co.jp/precure/'
    end

    def source_url
      return 'https://www.asahi.co.jp/precure/tropical/news/'
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
        source.xpath('//dl[@class="newswrap"]//li').each do |node|
          @entries.push({
            link: parse_url(node.search('dd//a').attribute('href').value).to_s,
            title: node.search('dd//a').inner_text,
            date: Time.parse(node.search('dt').inner_text),
          })
        rescue => e
          @logger.error(error: e)
        end
      end
      return @entries
    end
  end
end
