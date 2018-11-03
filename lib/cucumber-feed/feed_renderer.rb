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
require 'cucumber-feed/error/request'
require 'cucumber-feed/error/imprement'
require 'cucumber-feed/error/not_found'
require 'cucumber-feed/error/external_service'

module CucumberFeed
  class FeedRenderer < Renderer
    def initialize
      super
      type = 'rss'
    end

    def type=(name)
      case name.to_s
      when 'rss'
        @type = 'application/rss+xml; charset=UTF-8'
      when 'atom'
        @type = 'application/atom+xml; charset=UTF-8'
      else
        raise RequestError, "Invalid type '#{name || '(nil)'}'"
      end
    end

    def type
      return @type
    end

    def channel_title
      raise ImprementError, "#{__method__}が未定義です。"
    end

    def description
      return "「#{channel_title}」の新着情報"
    end

    def url
      raise ImprementError, "#{__method__}が未定義です。"
    end

    def source_url
      return url
    end

    def to_s
      crawl unless exist?
      return File.read(cache_path(type))
    rescue => e
      message = {
        feed: self.class.name,
        exception: e.class,
        message: e.message,
        backtrace: e.backtrace[0..5],
      }
      @logger.error(message)
      Slack.broadcast(message)
      raise NotFoundError, 'Cache not found.' unless File.exist?(cache_path(type))
      return File.read(cache_path(type))
    end

    def crawl
      File.write(digest_path, JSON.pretty_generate(digest))
      message = {digest: digest_path}
      [:atom, :rss].each do |type|
        path = cache_path(type)
        File.write(path, feed(type).to_s)
        message[type] = path
      end
      raise ExternalServiceError, 'Invalid contents' if contents_updated? && !entries_updated?
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
      require "cucumber-feed/renderer/#{name}_feed"
      return "CucumberFeed::#{name.capitalize}FeedRenderer".constantize.new
    end

    def self.all
      return enum_for(__method__) unless block_given?
      Config.instance['application']['feeds'].each do |name|
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
      raise ImprementError, "#{__method__}が未定義です。"
    end

    def feed(type)
      return ::RSS::Maker.make(create_feed_type(type)) do |maker|
        update_channel(maker.channel)
        maker.items.do_sort = true
        entries.each do |entry|
          handle_blank_title(entry) unless entry[:title].present?
          maker.items.new_item do |item|
            item.link = entry[:link]
            item.title = entry[:title]
            item.date = entry[:date]
            next unless entry[:image]
            url = parse_url(entry[:image])
            response = HTTParty.get(url)
            item.enclosure.url = url.to_s
            item.enclosure.length = response.body.length
            item.enclosure.type = response.headers['Content-Type']
          end
        end
      end
    end

    def update_channel(channel)
      channel.id = url
      channel.title = channel_title
      channel.description = description
      channel.link = url
      channel.author = @config['local']['author']
      channel.date = Time.now
      channel.generator = Package.user_agent
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

    def create_feed_type(type)
      return '2.0' if type.to_s == 'rss'
      return type.to_s
    end

    def create_extension(type)
      case type.to_s.split(/[\s;]+/).first.downcase
      when '', 'rss', 'application/rss+xml'
        return '.rss'
      when 'atom', 'application/atom+xml'
        return '.atom'
      else
        return nil
      end
    end

    def cache_path(type)
      return File.join(
        ROOT_DIR,
        'tmp/caches',
        Digest::SHA1.hexdigest(self.class.name) + create_extension(type),
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
      return false unless File.exist?(cache_path(:rss))
      return false unless File.exist?(cache_path(:atom))
      return false unless File.exist?(digest_path)
      return true
    end

    def sanitize(body)
      return Sanitize.clean(body)
    end
  end
end
