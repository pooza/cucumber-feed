namespace :cucumber do
  desc 'crawl'
  task :crawl do
    sh File.join(CucumberFeed::Environment.dir, 'bin/crawl.rb')
  end
end
