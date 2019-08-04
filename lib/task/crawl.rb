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
