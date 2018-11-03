require 'sinatra'
require 'active_support'
require 'active_support/core_ext'
require 'cucumber-feed/slack'
require 'cucumber-feed/config'
require 'cucumber-feed/renderer/xml'
require 'cucumber-feed/feed_renderer'
require 'cucumber-feed/package'
require 'cucumber-feed/logger'

module CucumberFeed
  class Server < Sinatra::Base
    def initialize
      super
      @config = Config.instance
      @logger = Logger.new
      @logger.info({
        message: 'starting...',
        server: {port: @config['thin']['port']},
      })
    end

    before do
      @message = {request: {path: request.path, params: params}, response: {}}
      @renderer = XMLRenderer.new
    end

    after do
      @message[:response][:status] ||= @renderer.status
      if @renderer.status < 400
        @logger.info(@message.select{ |k, v| [:request, :response, :package].member?(k)})
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

    get '/feed/v1.0/site/:site' do
      begin
        @renderer = FeedRenderer.create(params[:site])
        return @renderer.to_s
      rescue NameError
        @renderer = XMLRenderer.new
        @renderer.status = 404
        @message[:response][:message] = "#{params[:site].capitalize}FeedRenderer not found."
        @renderer.message = @message
        return @renderer.to_s
      end
    end

    not_found do
      @renderer = XMLRenderer.new
      @renderer.status = 404
      @message[:response][:message] = "Resource #{@message[:request][:path]} not found."
      @renderer.message = @message
      return @renderer.to_s
    end

    error do |e|
      @renderer = XMLRenderer.new
      @renderer.status = 500
      @message[:response][:message] = "#{e.class}: #{e.message}"
      @message[:backtrace] = e.backtrace[0..5]
      @renderer.message = @message
      Slack.broadcast(@message)
      return @renderer.to_s
    end
  end
end
