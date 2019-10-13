require 'bootsnap'

Bootsnap.setup(
  cache_dir: File.join(File.expand_path('..', __dir__), 'tmp/cache'),
  load_path_cache: true,
  autoload_paths_cache: true,
  compile_cache_iseq: true,
  compile_cache_yaml: true,
)

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
