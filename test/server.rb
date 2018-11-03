require 'cucumber-feed/config'
require 'addressable/uri'
require 'httparty'

module CucumberFeed
  class ServerTest < Test::Unit::TestCase
    def setup
      @config = Config.instance
    end

    def test_get
      @config['application']['feeds'].each do |key|
        ['.rss', '.atom', ''].each do |suffix|
          url = Addressable::URI.parse("http://localhost:#{@config['thin']['port']}")
          url.path = "/feed/v1.0/site/#{key}#{suffix}"
          response = HTTParty.get(url)
          assert_equal(response.code, 200)
          assert_true(response.to_s.present?)
          assert_equal(response.headers['content-type'], types[suffix])
        end
      end
    end

    def types
      return {
        '' => 'application/rss+xml; charset=UTF-8',
        '.rss' => 'application/rss+xml; charset=UTF-8',
        '.atom' => 'application/atom+xml; charset=UTF-8',
      }
    end
  end
end
