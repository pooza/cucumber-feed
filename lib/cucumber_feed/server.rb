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
      @message = {request: {path: request.path, params: params}, response: {}}
      @renderer = XmlRenderer.new
    end

    after do
      @message[:response][:status] ||= @renderer.status
      if @renderer.status < 400
        @logger.info(@message)
      else
        @logger.error(@message)
      end
      status @renderer.status
      content_type @renderer.type
    end

    get '/about' do
      @message[:response][:message] = Package.full_name
      @renderer.message = @message
      return @renderer.to_s
    end

    get '/feed/v1.0/site/:name' do
      site, type = params[:name].split('.')
      type ||= 'rss'
      @renderer = FeedRenderer.create(site)
      @renderer.type = type
      return @renderer.to_s
    rescue LoadError
      raise NotFoundError, "Resource #{@message[:request][:path]} not found."
    end

    not_found do
      @renderer = XmlRenderer.new
      @renderer.status = 404
      @message[:response][:message] = "Resource #{@message[:request][:path]} not found."
      @renderer.message = @message
      return @renderer.to_s
    end

    error do |e|
      @renderer = XmlRenderer.new
      begin
        @renderer.status = e.status
      rescue NoMethodError
        @renderer.status = 500
      end
      @message[:response][:message] = "#{e.class}: #{e.message}"
      @message[:backtrace] = e.backtrace[0..5]
      @renderer.message = @message
      Slack.broadcast(@message)
      return @renderer.to_s
    end
  end
end
