module CucumberFeed
  class ToeiFeedRendererTest < Test::Unit::TestCase
    def setup
      @renderer = FeedRenderer.create('toei')
    end

    def test_crawl
      result = @renderer.crawl
      assert_true(File.exist?(result[:atom]))
      assert_true(File.exist?(result[:rss]))
      assert_true(File.exist?(result[:digest]))
    end

    def test_to_s
      @renderer.type = 'rss'
      assert_true(@renderer.to_s.present?)
      assert_equal(@renderer.type, 'application/rss+xml; charset=UTF-8')
      @renderer.type = 'atom'
      assert_true(@renderer.to_s.present?)
      assert_equal(@renderer.type, 'application/atom+xml; charset=UTF-8')
    end
  end
end
