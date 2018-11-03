require 'json'
require 'syslog/logger'
require 'cucumber-feed/package'

module CucumberFeed
  class Logger
    def initialize
      @logger = Syslog::Logger.new(Package.name)
    end

    def info(message)
      @logger.info(message.to_json)
    end

    def warn(message)
      @logger.warn(message.to_json)
    end

    def error(message)
      @logger.error(message.to_json)
    end

    def fatal(message)
      @logger.fatal(message.to_json)
    end
  end
end
