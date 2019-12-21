desc 'test all'
task :test do
  ENV['TEST'] = CucumberFeed::Package.name
  require 'test/unit'
  Dir.glob(File.join(CucumberFeed::Environment.dir, 'test/*.rb')).sort.each do |t|
    require t
  end
end
