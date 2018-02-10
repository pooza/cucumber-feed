require 'yaml'

module CucumberFeed
  class Config < Hash
    def initialize
      super
      Dir.glob(File.join(ROOT_DIR, 'config', '*.yaml')).each do |f|
        self[File.basename(f, '.yaml')] = YAML.load_file(f)
      end
      self['local'] ||= {}
      self['local']['entries'] ||= {'default' => 50, 'max' => 200}
    end
  end
end
