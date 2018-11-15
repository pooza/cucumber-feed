require 'sinatra'

module CucumberFeed
  class Server < Sinatra::Base
    def initialize
      super
      @config = Config.instance
      @logger = Logger.new
      @logger.info({
        message: 'starting...',
        server: {port: @config['thin']['port']},
        version: Package.version,
      })
    end

    before do
      @logger.info({request: {path: request.path, params: params}})
      @headers = request.env.select{ |k, v| k.start_with?('HTTP_')}
      @renderer = XmlRenderer.new
    end

    after do
      status @renderer.status
      content_type @renderer.type
    end

    get '/about' do
      @renderer.message = Package.full_name
      return @renderer.to_s
    end

    get '/feed/v1.0/site/:name' do
      site, type = params[:name].split('.')
      type ||= 'rss'
      @renderer = FeedRenderer.create(site)
      @renderer.type = type
      return @renderer.to_s
    rescue LoadError
      raise NotFoundError, "Resource #{request.path} not found."
    end

    not_found do
      @renderer = XmlRenderer.new
      @renderer.status = 404
      @renderer.message = "Resource #{request.path} not found."
      return @renderer.to_s
    end

    error do |e|
      e = Error.create(e)
      @renderer = XmlRenderer.new
      @renderer.status = e.status
      @renderer.message = "#{e.class}: #{e.message}"
      Slack.broadcast(e.to_h)
      @logger.error(e.to_h)
      return @renderer.to_s
    end
  end
end
