ROOT_DIR = File.expand_path(__dir__)
$LOAD_PATH.push(File.join(ROOT_DIR, 'lib'))
ENV['BUNDLE_GEMFILE'] ||= File.join(ROOT_DIR, 'Gemfile')
ENV['SSL_CERT_FILE'] ||= File.join(ROOT_DIR, 'cert/cacert.pem')

require 'bundler/setup'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies/autoload'
require 'cucumber_feed'
run CucumberFeed::Server
