module CucumberFeed
  class Environment < Ginseng::Environment
    def self.name
      return File.basename(dir)
    end

    def self.dir
      return CucumberFeed.dir
    end
  end
end
