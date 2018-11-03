require 'cucumber-feed/config'
require 'cucumber-feed/logger'
require 'cucumber-feed/error/imprement'

module CucumberFeed
  class Renderer
    attr_accessor :status

    def initialize
      @status = 200
      @config = Config.instance
      @logger = Logger.new
    end

    def type
      return 'application/xml; charset=UTF-8'
    end

    def to_s
      raise ImprementError, "#{__method__}が未定義です。"
    end
  end
end
