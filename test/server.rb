require 'rack/test'

module CucumberFeed
  class ServerTest < Test::Unit::TestCase
    include ::Rack::Test::Methods

    def setup
      @config = Config.instance
      @types = {
        '' => 'application/rss+xml; charset=UTF-8',
        '.rss' => 'application/rss+xml; charset=UTF-8',
        '.atom' => 'application/atom+xml; charset=UTF-8',
      }
    end

    def app
      return Server
    end

    def test_get
      get create_url('/error').to_s
      assert_false(last_response.ok?)
      assert_equal(last_response.status, 404)

      get create_url('/feed/v1.0/site/abc1').to_s
      assert_false(last_response.ok?)
      assert_equal(last_response.status, 404)

      get create_url('/feed/v1.0/site/abc.rss2').to_s
      assert_false(last_response.ok?)
      assert_equal(last_response.status, 400)

      return if Environment.ci?
      @config['/feeds'].each do |key|
        ['.rss', '.atom', ''].freeze.each do |suffix|
          get create_url("/feed/v1.0/site/#{key}#{suffix}").to_s
          assert(last_response.ok?)
          assert_equal(last_response.headers['content-type'], @types[suffix])
        end
      end
    end

    private

    def create_url(href)
      url = Ginseng::URI.parse('http://localhost')
      url.port = @config['/puma/port'].to_i
      url.path = href
      return url
    end
  end
end
