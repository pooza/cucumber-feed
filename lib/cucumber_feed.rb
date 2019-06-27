require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies/autoload'
require 'ginseng'
require 'ginseng/web'

module CucumberFeed
  extend ActiveSupport::Autoload

  autoload :Config
  autoload :Environment
  autoload :FeedRenderer
  autoload :HTTP
  autoload :Logger
  autoload :Package
  autoload :Server
  autoload :Slack

  autoload_under 'daemon' do
    autoload :ThinDaemon
  end
end
