require 'cucumber-feed/config'
require 'addressable/uri'
require 'httparty'

module CucumberFeed
  class ServerTest < Test::Unit::TestCase
    def setup
      @config = Config.instance
    end

    def test_get
      @config['application']['atom'].each do |key|
        url = Addressable::URI.parse("http://localhost:#{@config['thin']['port']}")
        url.path = "/feed/v1.0/site/#{key}"
        assert_true(HTTParty.get(url).to_s.present?)
      end
    end
  end
end
