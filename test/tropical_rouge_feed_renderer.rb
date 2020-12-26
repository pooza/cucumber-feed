module CucumberFeed
  class TropicalRougeFeedRendererTest < Test::Unit::TestCase
    def setup
      @renderer = FeedRenderer.create('tropical_rouge')
      return if Environment.ci?
      @config = Config.instance
      @config['/slack/hooks'] = []
    end

    def test_crawl
      result = @renderer.crawl
      assert(File.exist?(result[:atom]))
      assert(File.exist?(result[:rss]))
      assert(File.exist?(result[:digest]))
    end

    def test_to_s
      @renderer.type = 'rss'
      assert(@renderer.to_s.present?)
      assert_equal(@renderer.type, 'application/rss+xml; charset=UTF-8')
      @renderer.type = 'atom'
      assert(@renderer.to_s.present?)
      assert_equal(@renderer.type, 'application/atom+xml; charset=UTF-8')
    end

    def test_parse_url
      uri = @renderer.parse_url('../character/')
      pp uri.to_s
    end
  end
end
