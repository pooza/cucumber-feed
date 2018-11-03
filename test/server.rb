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
          response = HTTParty.get(create_url("/feed/v1.0/site/#{key}#{suffix}"))
          assert_equal(response.code, 200)
          assert_true(response.to_s.present?)
          assert_equal(response.headers['content-type'], types[suffix])
        end
      end
      assert_equal(HTTParty.get(create_url('/feed/v1.0/site/abc1')).code, 404)
      assert_equal(HTTParty.get(create_url('/feed/v1.0/site/abc.rss2')).code, 400)
    end

    def create_url(href)
      url = Addressable::URI.parse("http://localhost:#{@config['thin']['port']}")
      url.path = href
      return url
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
