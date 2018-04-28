require 'rss'
require 'digest/sha1'
require 'open-uri'
require 'cucumber-feed/package'
require 'cucumber-feed/renderer'
require 'sanitize'

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

    def headers
      return {
        'User-Agent' => "#{Package.full_name} #{Package.url}",
      }
    end

    def to_s
      if !File.exist?(cache_path) || expired?
        File.write(cache_path, atom.to_s)
      end
      return File.read(cache_path)
    rescue => e
      message = {
        feed: self.class.name,
        exception: e.class,
        message: e.message,
      }
      Logger.new.error(message)
      Slack.new.say(message) if @config['local']['slack']
      raise 'Feed not cached.' unless File.exist?(cache_path)
      return File.read(cache_path)
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

    def cache_path
      return File.join(
        ROOT_DIR,
        'tmp/caches',
        Digest::SHA1.hexdigest(self.class.name) + '.atom',
      )
    end

    def expired?
      return (
        File.mtime(cache_path) < (Time.now - @config['application']['minutes'].minutes)
      )
    end

    protected
    def sanitize (body)
      return Sanitize.clean(body)
    end
  end
end
