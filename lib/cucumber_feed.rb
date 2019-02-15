require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies/autoload'
require 'ginseng'

module CucumberFeed
  extend ActiveSupport::Autoload

  autoload :Config
  autoload :Environment
  autoload :FeedRenderer
  autoload :Logger
  autoload :Package
  autoload :Server
  autoload :Slack

  autoload_under 'daemon' do
    autoload :ThinDaemon
  end
end
