require 'rss'
require 'digest/sha1'
require 'sanitize'

module CucumberFeed
  class FeedRenderer < Ginseng::Web::Renderer
    include Package

    def initialize
      super
      @http = HTTP.new
      self.type = 'rss'
    end

    def type=(name)
      case name.to_s
      when 'rss'
        @type = 'application/rss+xml; charset=UTF-8'
      when 'atom'
        @type = 'application/atom+xml; charset=UTF-8'
      else
        raise Ginseng::RequestError, "Invalid type '#{name || '(nil)'}'"
      end
    end

    def type
      return @type
    end

    def channel_title
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def description
      return "「#{channel_title}」の新着情報"
    end

    def url
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def source_url
      return url
    end

    def to_s
      crawl unless exist?
      return File.read(cache_path(type))
    rescue => e
      e = Ginseng::Error.create(e)
      message = e.to_h
      message[:feed] = self.class.name
      Slack.broadcast(message)
      @logger.error(message)
      raise Ginseng::NotFoundError, 'Cache not found.' unless File.exist?(cache_path(type))
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
      raise Ginseng::GatewayError, 'Invalid contents' if contents_updated? && !entries_updated?
      @logger.info(message)
      return message
    rescue => e
      e = Ginseng::Error.create(e)
      message = e.to_h
      message[:feed] = self.class.name
      Slack.broadcast(message)
      @logger.error(message)
    end

    def self.create(name)
      return "CucumberFeed::#{name.classify}FeedRenderer".constantize.new
    end

    def self.all
      return enum_for(__method__) unless block_given?
      Config.instance['/feeds'].each do |name|
        yield create(name)
      end
    end

    private

    def entries
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def feed(type)
      return RSS::Maker.make(create_feed_type(type)) do |maker|
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
            response = @http.get(url)
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
      channel.author = @config['/author']
      channel.date = Time.now
      channel.generator = Package.user_agent
    end

    def handle_blank_title(entry)
      message = {feed: self.class.name, message: 'Blank title'}
      message.update(entry)
      Slack.broadcast(message)
      @logger.error(message)
    end

    def parse_url(href)
      url = Ginseng::URI.parse(href)
      unless url.absolute?
        local_url = url
        url = Ginseng::URI.parse(self.url)
        url.path = local_url.path
        url.query = local_url.query
        url.fragment = local_url.fragment
      end
      return url
    end

    def contents
      @contents ||= @http.get(url).to_s
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
        Environment.dir,
        'tmp/caches',
        Digest::SHA1.hexdigest(self.class.name) + create_extension(type),
      )
    end

    def digest_path
      return File.join(
        Environment.dir,
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
