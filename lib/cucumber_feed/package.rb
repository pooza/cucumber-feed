module CucumberFeed
  module Package
    def module_name
      return 'CucumberFeed'
    end

    def environment_class
      return "CucumberFeed::Environment".constantize
    end

    def package_class
      return "CucumberFeed::Package".constantize
    end

    def config_class
      return "CucumberFeed::Config".constantize
    end

    def logger_class
      return "CucumberFeed::Logger".constantize
    end

    def http_class
      return "CucumberFeed::HTTP".constantize
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
