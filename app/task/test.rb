desc 'test all'
task :test do
  CucumberFeed::TestCase.load
end
