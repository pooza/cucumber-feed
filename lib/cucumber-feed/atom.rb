require 'rss'
require 'open-uri'
require 'cucumber-feed/renderer'

module CucumberFeed
  class Atom < Renderer
    def type
      return 'application/atom+xml; charset=UTF-8'
    end

    def channel_title
      raise 'チャンネルタイトルが未定義です。'
    end

    def url
      raise 'フィードのURLが未定義です。'
    end

    def source_url
      return url
    end

    def to_s
      return atom.to_s
    end

    protected
    def entries
      raise 'entriesが未実装です。'
    end

    def atom
      return RSS::Maker.make('atom') do |maker|
        maker.channel.id = url
        maker.channel.title = channel_title
        maker.channel.description = "「#{channel_title}」の新着情報"
        maker.channel.link = url
        maker.channel.author = @config['local']['author']
        maker.channel.date = Time.now
        maker.items.do_sort = true

        entries.each do |entry|
          maker.items.new_item do |item|
            item.link = entry[:link]
            item.title = entry[:title]
            item.date = entry[:date]
          end
        end
      end
    end

    def parse_url (href)
      url = URI::parse(href)
      unless url.scheme
        local_url = url
        url = URI::parse(self.url)
        url.path = local_url.path
        url.query = local_url.query
        url.fragment = local_url.fragment
      end
      return url
    end
  end
end
