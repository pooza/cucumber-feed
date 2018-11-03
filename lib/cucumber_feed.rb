require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies/autoload'

module CucumberFeed
  extend ActiveSupport::Autoload

  autoload :Config
  autoload :FeedRenderer
  autoload :Logger
  autoload :Package
  autoload :Renderer
  autoload :Server
  autoload :Slack
  autoload :ConfigError, 'cucumber_feed/error/config'
  autoload :ExternalServiceError, 'cucumber_feed/error/external_service'
  autoload :ImprementError, 'cucumber_feed/error/imprement'
  autoload :NotFoundError, 'cucumber_feed/error/not_found'
  autoload :RequestError, 'cucumber_feed/error/request'
  autoload :XmlRenderer, 'cucumber_feed/renderer/xml'
end
