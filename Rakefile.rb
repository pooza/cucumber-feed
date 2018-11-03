ROOT_DIR = File.expand_path(__dir__)
$LOAD_PATH.push(File.join(ROOT_DIR, 'lib'))
ENV['BUNDLE_GEMFILE'] ||= File.join(ROOT_DIR, 'Gemfile')
ENV['SSL_CERT_FILE'] ||= File.join(ROOT_DIR, 'cert/cacert.pem')

require 'bundler/setup'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies/autoload'
require 'cucumber_feed'

desc 'test'
task :test do
  require 'test/unit'
  Dir.glob(File.join(ROOT_DIR, 'test/*')).each do |t|
    require t
  end
end

desc 'crawl feeds'
task 'crawl' do
  sh File.join(ROOT_DIR, 'crawl.rb')
end

[:start, :stop, :restart].each do |action|
  desc "alias of server:#{action}"
  task action => ["server:#{action}"]
end

namespace :server do
  [:start, :stop, :restart].each do |action|
    desc "#{action} server"
    task action do
      sh "thin --config config/thin.yaml #{action}"
    end
  end
end
