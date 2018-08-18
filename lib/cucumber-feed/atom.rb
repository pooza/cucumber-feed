require 'rss'
require 'digest/sha1'
require 'addressable/uri'
require 'httparty'
require 'sanitize'
require 'json'
require 'cucumber-feed/package'
require 'cucumber-feed/renderer'
require 'cucumber-feed/slack'
require 'cucumber-feed/logger'

module CucumberFeed
  class Atom < Renderer
    def type
      return 'application/atom+xml; charset=UTF-8'
    end

    def channel_title
      raise 'チャンネルタイトルが未定義です。'
    end

    def description
      return "「#{channel_title}」の新着情報"
    end

    def url
      raise 'フィードのURLが未定義です。'
    end

    def source_url
      return url
    end

    def to_s
      crawl unless exist?
      return File.read(cache_path)
    rescue => e
      message = {
        feed: self.class.name,
        exception: e.class,
        message: e.message,
        backtrace: e.backtrace[0..5],
      }
      @logger.error(message)
      Slack.broadcast(message)
      raise 'Feed not cached.' unless File.exist?(cache_path)
      return File.read(cache_path)
    end

    def crawl
      File.write(cache_path, atom.to_s)
      File.write(digest_path, JSON.pretty_generate(digest))
      raise 'Error: fetching entries' if contents_updated? && !entries_updated?
      message = {
        feed: self.class.name,
        cache_path: cache_path,
        digest_path: digest_path,
      }
      @logger.info(message)
      return message
    rescue => e
      message = {
        feed: self.class.name,
        exception: e.class,
        message: e.message,
        backtrace: e.backtrace[0..5],
      }
      @logger.error(message)
      Slack.broadcast(message)
    end

    def self.create(name)
      require "cucumber-feed/atom/#{name}"
      return "CucumberFeed::#{name.capitalize}Atom".constantize.new
    end

    def self.all
      return enum_for(__method__) unless block_given?
      Config.instance['application']['atom'].each do |name|
        yield create(name)
      end
    end

    protected

    def headers
      return {
        'User-Agent' => Package.user_agent,
      }
    end

    def entries
      raise 'entriesが未実装です。'
    end

    def atom
      return RSS::Maker.make('atom') do |maker|
        maker.channel.id = url
        maker.channel.title = channel_title
        maker.channel.description = description
        maker.channel.link = url
        maker.channel.author = @config['local']['author']
        maker.channel.date = Time.now
        maker.items.do_sort = true

        entries.each do |entry|
          handle_blank_title(entry) unless entry[:title].present?
          maker.items.new_item do |item|
            item.link = entry[:link]
            item.title = entry[:title]
            item.date = entry[:date]
          end
        end
      end
    end

    def handle_blank_title(entry)
      message = {feed: self.class.name, message: 'Blank title'}
      message.update(entry)
      @logger.error(message)
      Slack.broadcast(message)
    end

    def parse_url(href)
      url = Addressable::URI.parse(href)
      unless url.absolute?
        local_url = url
        url = Addressable::URI.parse(self.url)
        url.path = local_url.path
        url.query = local_url.query
        url.fragment = local_url.fragment
      end
      return url
    end

    def contents
      @contents ||= HTTParty.get(url, {
        headers: headers,
      }).to_s
      return @contents
    end

    def digest
      return {
        contents: Digest::SHA1.hexdigest(contents),
        entries: Digest::SHA1.hexdigest(entries.to_json),
      }
    end

    def prev_digest
      return JSON.parse(File.read(digest_path), {symbolize_names: true})
    end

    def contents_updated?
      return (digest[:contents] != prev_digest[:contents])
    end

    def entries_updated?
      return (digest[:entries] != prev_digest[:entries])
    end

    def cache_path
      return File.join(
        ROOT_DIR,
        'tmp/caches',
        Digest::SHA1.hexdigest(self.class.name) + '.atom',
      )
    end

    def digest_path
      return File.join(
        ROOT_DIR,
        'tmp/digests',
        Digest::SHA1.hexdigest(self.class.name) + '.sha1',
      )
    end

    def exist?
      return File.exist?(cache_path) && File.exist?(digest_path)
    end

    def sanitize(body)
      return Sanitize.clean(body)
    end
  end
end
