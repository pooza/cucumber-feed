module CucumberFeed
  module Package
    def environment_class
      return 'CucumberFeed::Environment'
    end

    def package_class
      return 'CucumberFeed::Package'
    end

    def config_class
      return 'CucumberFeed::Config'
    end

    def logger_class
      return 'CucumberFeed::Logger'
    end

    def self.name
      return 'cucumber-feed'
    end

    def self.version
      return Config.instance['/package/version']
    end

    def self.url
      return Config.instance['/package/url']
    end

    def self.full_name
      return "#{name} #{version}"
    end

    def self.user_agent
      return "#{name}/#{version} (#{url})"
    end
  end
end
