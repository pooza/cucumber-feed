module CucumberFeed
  extend ActiveSupport::Autoload

  autoload :Config, 'cucumber_feed/config'
  autoload :FeedRenderer, 'cucumber_feed/feed_renderer'
  autoload :Logger, 'cucumber_feed/logger'
  autoload :Package, 'cucumber_feed/package'
  autoload :Renderer, 'cucumber_feed/renderer'
  autoload :Server, 'cucumber_feed/server'
  autoload :Slack, 'cucumber_feed/slack'
  autoload :ConfigError, 'cucumber_feed/error/config'
  autoload :ExternalServiceError, 'cucumber_feed/error/external_service'
  autoload :ImprementError, 'cucumber_feed/error/imprement'
  autoload :NotFoundError, 'cucumber_feed/error/not_found'
  autoload :RequestError, 'cucumber_feed/error/request'
  autoload :XMLRenderer, 'cucumber_feed/renderer/xml'
end
