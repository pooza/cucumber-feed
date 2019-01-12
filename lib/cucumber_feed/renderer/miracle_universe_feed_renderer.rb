require 'time'
require 'httparty'
require 'json'

module CucumberFeed
  class MiracleUniverseFeedRenderer < FeedRenderer
    def channel_title
      return '映画プリキュアミラクルユニバース公式'
    end

    def url
      return 'http://www.precure-miracleuniverse.com'
    end

    def source_url
      return 'http://toei.lekumo.biz/precureallstars/feed.js'
    end

    private

    def entries
      unless @entries
        @entries = []
        contents = HTTParty.get(source_url, {headers: headers})
        JSON.parse(contents.match(/"entry":\s*(\[.*?\])/m)[1]).each do |entry|
          @entries.push({
            link: entry['link'],
            title: entry['title'],
            date: Time.parse(entry['updated']),
          })
        end
      end
      return @entries
    end
  end
end
