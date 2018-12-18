require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies/autoload'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'XML'
end

module CucumberFeed
  extend ActiveSupport::Autoload

  autoload :Config
  autoload :Environment
  autoload :Error
  autoload :FeedRenderer
  autoload :Logger
  autoload :Package
  autoload :Renderer
  autoload :Server
  autoload :Slack

  autoload_under 'error' do
    autoload :ConfigError
    autoload :ExternalServiceError
    autoload :ImplementError
    autoload :NotFoundError
    autoload :RequestError
  end

  autoload_under 'renderer' do
    autoload :XMLRenderer
  end
end
