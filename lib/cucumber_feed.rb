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

  autoload_under 'error' do
    autoload :ConfigError
    autoload :ExternalServiceError
    autoload :ImprementError
    autoload :NotFoundError
    autoload :RequestError
  end

  autoload_under 'renderer' do
    autoload :XmlRenderer
  end
end
