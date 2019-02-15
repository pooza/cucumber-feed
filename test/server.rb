require 'addressable/uri'
require 'rack/test'

module CucumberFeed
  class ServerTest < Test::Unit::TestCase
    include ::Rack::Test::Methods

    def setup
      @config = Config.instance
    end

    def app
      return Server
    end

    def test_get
      @config['/feeds'].each do |key|
        ['.rss', '.atom', ''].each do |suffix|
          get create_url("/feed/v1.0/site/#{key}#{suffix}").to_s
          assert(last_response.ok?)
          assert_equal(last_response.headers['content-type'], types[suffix])
        end
      end

      get create_url('/error').to_s
      assert_false(last_response.ok?)

      get create_url('/feed/v1.0/site/abc1').to_s
      assert_false(last_response.ok?)

      get create_url('/feed/v1.0/site/abc.rss2').to_s
      assert_false(last_response.ok?)
    end

    private

    def create_url(href)
      url = Addressable::URI.parse('http://localhost')
      url.port = @config['/thin/port'].to_i
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
