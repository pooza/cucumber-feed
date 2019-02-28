namespace :cucumber do
  task :test do
    ENV['TEST'] = CucumberFeed::Package.name
    require 'test/unit'
    Dir.glob(File.join(CucumberFeed::Environment.dir, 'test/*')).each do |t|
      require t
    end
  end
end
