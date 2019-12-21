dir = File.expand_path(__dir__)
$LOAD_PATH.unshift(File.join(dir, 'app/lib'))
ENV['BUNDLE_GEMFILE'] ||= File.join(dir, 'Gemfile')

require 'bundler/setup'
require 'cucumber_feed'

[:start, :stop, :restart].each do |action|
  desc "#{action} all"
  task action => "cucumber:thin:#{action}"
end

[:crawl, :run].each do |action|
  desc "alias of cucumber:#{action}"
  task action => "cucumber:#{action}"
end

Dir.glob(File.join(CucumberFeed::Environment.dir, 'app/task/*.rb')).sort.each do |f|
  require f
end
