module CucumberFeed
  class Environment < Ginseng::Environment
    def self.name
      return File.basename(dir)
    end

    def self.dir
      return CucumberFeed.dir
    end

    def self.type
      return Config.instance['/environment'] || 'development'
    end

    def self.development?
      return type == 'development'
    end

    def self.production?
      return type == 'production'
    end
  end
end
