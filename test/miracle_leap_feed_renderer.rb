module CucumberFeed
  class MiracleLeapFeedRendererTest < Test::Unit::TestCase
    def setup
      @renderer = FeedRenderer.create('miracle_leap')
      return if Environment.ci?
      @config = Config.instance
      @config['/slack/hooks'] = []
    end

    def test_crawl
      return if Environment.ci?
      result = @renderer.crawl
      assert(File.exist?(result[:atom]))
      assert(File.exist?(result[:rss]))
      assert(File.exist?(result[:digest]))
    end

    def test_to_s
      return if Environment.ci?
      @renderer.type = 'rss'
      assert(@renderer.to_s.present?)
      assert_equal(@renderer.type, 'application/rss+xml; charset=UTF-8')
      @renderer.type = 'atom'
      assert(@renderer.to_s.present?)
      assert_equal(@renderer.type, 'application/atom+xml; charset=UTF-8')
    end
  end
end
