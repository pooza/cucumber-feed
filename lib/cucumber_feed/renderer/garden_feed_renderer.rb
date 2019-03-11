require 'nokogiri'
require 'time'
require 'addressable/uri'

module CucumberFeed
  class GardenFeedRenderer < FeedRenderer
    def channel_title
      return 'プリキュアガーデン'
    end

    def url
      return 'http://www.toei-anim.co.jp/ptr/precure/'
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
        path = '//div[@class="boxMain box--mainTopics box--top"]//a[@class="card__box"]'
        source.xpath(path).each do |node|
          @entries.push({
            link: Addressable::URI.parse(url + node.attribute('href')).to_s,
            title: node.search('p[@class="card__text"]').inner_text,
            date: Time.parse(node.search('p[@class="card__date card__icon--new"]').inner_text),
            image: node.search('img').attribute('src').value,
          })
        end
      end
      return @entries
    end
  end
end
