dir = File.expand_path('../..', __dir__)
$LOAD_PATH.unshift(File.join(dir, 'app/lib'))
ENV['BUNDLE_GEMFILE'] = File.join(dir, 'Gemfile')
require 'cucumber_feed'

config = CucumberFeed::Config.instance
port config['/puma/port']
pidfile File.join(dir, config['/puma/pidfile'])
rackup File.join(dir, config['/puma/rackup'])
