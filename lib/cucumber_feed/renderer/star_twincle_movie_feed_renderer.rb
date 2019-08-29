require 'time'

module CucumberFeed
  class StarTwincleMovieFeedRenderer < FeedRenderer
    def channel_title
      return '映画 スター☆トゥインクルプリキュア公式'
    end

    def url
      return 'https://www.precure-movie.com/'
    end

    def source_url
      return 'https://toei.lekumo.biz/precure_movie_news/feed.js'
    end

    private

    def source
      @source ||= @http.get(source_url)
      return @source
    end

    def entries
      unless @entries
        @entries = []
        matches = source.match(/"entry": (\[.*?\])/m)
        JSON.parse(matches[1]).each do |entry|
          @entries.push(
            link: entry['link'],
            title: entry['title'],
            date: Time.parse(entry['published']),
          )
        end
      end
      return @entries
    rescue
      return []
    end
  end
end
