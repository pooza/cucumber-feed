require 'active_support'
require 'active_support/core_ext'
require 'syslog/logger'
require 'cucumber-feed/config'
require 'cucumber-feed/xml'

module CucumberFeed
  class Application < Sinatra::Base
    def initialize
      super
      @config = Config.new
      @logger = Syslog::Logger.new(@config['application']['name'])
      @logger.info({
        message: 'starting...',
        package: {
          name: @config['application']['name'],
          version: @config['application']['version'],
        },
        server: {
          port: @config['thin']['port'],
        },
      }.to_json)
    end

    before do
      @message = {request:{path: request.path, params:params}, response:{}}
      @renderer = XML.new
    end

    after do
      @message[:response][:status] ||= @renderer.status
      if (@renderer.status < 300)
        @logger.info(@message.to_json)
      else
        @logger.error(@message.to_json)
      end
      status @renderer.status
      content_type @renderer.type
    end

    get '/about' do
      @message[:response][:status] = @renderer.status
      @message[:response][:message] = '%s %s'%([
        @config['application']['name'],
        @config['application']['version'],
      ])
      return @renderer.generate(@message).to_s
    end

    get '/feed/v1.0/site/toei' do
      require 'cucumber-feed/atom/toeiatom'
      @renderer = ToeiAtom.new
      @renderer.title_length = params[:length]
      @renderer.entries = params[:entries]
      return @renderer.to_s
    end

    get '/feed/v1.0/site/abc' do
      require 'cucumber-feed/atom/abcatom'
      @renderer = ABCAtom.new
      @renderer.title_length = params[:length]
      @renderer.entries = params[:entries]
      return @renderer.to_s
    end

    get '/feed/v1.0/site/garden' do
      require 'cucumber-feed/atom/gardenatom'
      @renderer = GardenAtom.new
      @renderer.title_length = params[:length]
      @renderer.entries = params[:entries]
      return @renderer.to_s
    end

    not_found do
      @renderer = XML.new
      @renderer.status = 404
      @message[:response][:status] = @renderer.status
      @message[:response][:message] = "Resource #{@message[:request][:path]} not found."
      return @renderer.generate(@message).to_s
    end

    error do
      @renderer = XML.new
      @renderer.status = 500
      @message[:response][:status] = @renderer.status
      @message[:response][:message] = env['sinatra.error'].message
      return @renderer.generate(@message).to_s
    end
  end
end
