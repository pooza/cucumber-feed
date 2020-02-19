namespace :cucumber do
  desc 'crawl (silence)'
  task :run do
    system File.join(CucumberFeed::Environment.dir, 'bin/crawl.rb')
  end

  desc 'crawl'
  task :crawl do
    sh File.join(CucumberFeed::Environment.dir, 'bin/crawl.rb')
  end
end

[:crawl, :run].each do |action|
  desc "alias of cucumber:#{action}"
  task action => "cucumber:#{action}"
end
