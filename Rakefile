dir = File.expand_path(__dir__)
$LOAD_PATH.unshift(File.join(dir, 'lib'))
ENV['BUNDLE_GEMFILE'] ||= File.join(dir, 'Gemfile')

require 'bundler/setup'
require 'cucumber_feed'

desc 'test all'
task test: ['cucumber:test']

[:start, :stop, :restart].each do |action|
  desc "#{action} all"
  task action => "cucumber:thin:#{action}"
end

Dir.glob(File.join(CucumberFeed::Environment.dir, 'lib/task/*.rb')).each do |f|
  require f
end
