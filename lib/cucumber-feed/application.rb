require 'active_support'
require 'active_support/core_ext'
require 'syslog/logger'
require 'cucumber-feed/slack'
require 'cucumber-feed/config'
require 'cucumber-feed/xml'
require 'cucumber-feed/html'
require 'cucumber-feed/atom/toei'
require 'cucumber-feed/atom/abc'
require 'cucumber-feed/atom/garden'

module CucumberFeed
  class Application < Sinatra::Base
    def initialize
      super
      @config = Config.instance
      @slack = Slack.new if @config['local']['slack']
      Application.logger.info({
        message: 'starting...',
        package: {
          name: Application.name,
          version: Application.version,
          url: Application.url,
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
      if (@renderer.status < 400)
        Application.logger.info(@message.to_json)
      else
        Application.logger.error(@message.to_json)
      end
      status @renderer.status
      content_type @renderer.type
    end

    ['/', '/index'].each do |route|
      get route do
        @renderer = HTML.new
        @renderer.template_file = 'index.erb'
        return @renderer.to_s
      end
    end

    get '/about' do
      @message[:response][:message] = Application.full_name
      @renderer.message = @message
      return @renderer.to_s
    end

    get '/feed/v1.0/site/:site' do
      begin
        @renderer = "CucumberFeed::#{params[:site].capitalize}Atom".constantize.new
        return @renderer.to_s
      rescue NameError => e
        @renderer = XML.new
        @renderer.status = 404
        @message[:response][:message] = "#{params[:site].capitalize}Atom not found."
        @renderer.message = @message
        return @renderer.to_s
      end
    end

    not_found do
      @renderer = XML.new
      @renderer.status = 404
      @message[:response][:message] = "Resource #{@message[:request][:path]} not found."
      @renderer.message = @message
      return @renderer.to_s
    end

    error do
      @renderer = XML.new
      @renderer.status = 500
      @message[:response][:message] = env['sinatra.error'].message
      @renderer.message = @message
      @slack.say(message) if @slack
      return @renderer.to_s
    end

    def self.name
      return Config.instance['application']['name']
    end

    def self.version
      return Config.instance['application']['version']
    end

    def self.url
      return Config.instance['application']['url']
    end

    def self.full_name
      return "#{Application.name} #{Application.version}"
    end

    def self.logger
      return Syslog::Logger.new(Application.name)
    end
  end
end
