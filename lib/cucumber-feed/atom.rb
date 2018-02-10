require 'rss'
require 'nokogiri'
require 'open-uri'
require 'cucumber-feed/renderer'
require 'cucumber-feed/config'

module CucumberFeed
  class Atom < Renderer
    def initialize
      super
      @config = Config.new
    end

    def type
      return 'application/atom+xml; charset=UTF-8'
    end

    def channel_title
      raise 'チャンネルタイトルが未定義です。'
    end

    def url
      raise 'フィードのURLが未定義です。'
    end

    def title_length= (length)
      @title_length = length.to_i unless length.nil?
    end

    def entries= (entries)
      @entries = entries.to_i unless entries.nil?
    end

    def to_s
      return atom.to_s
    end

    protected
    def source
      unless @sourcce
        html = open(url) do |f|
          f.read
        end
        @source = Nokogiri::HTML.parse(html.force_encoding('utf-8'), nil, 'utf-8')
      end
      return @source
    end

    def entries
      raise 'entriesが未実装です。'
    end

    def atom
      return RSS::Maker.make('atom') do |maker|
        maker.channel.id = url
        maker.channel.title = channel_title
        maker.channel.description = "「#{channel_title}」の新着情報"
        maker.channel.link = url
        maker.channel.author = @config['application']['author']
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
  end
end
