dir = File.expand_path('../..', __dir__)
$LOAD_PATH.unshift(File.join(dir, 'app/lib'))
ENV['BUNDLE_GEMFILE'] ||= File.join(dir, 'Gemfile')
require 'cucumber_feed'

run CucumberFeed::Server
