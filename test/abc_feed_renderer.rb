require 'cucumber-feed/renderer/abc_feed'

module CucumberFeed
  class AbcFeedRendererTest < Test::Unit::TestCase
    def setup
      @rss = AbcFeedRenderer.new
    end

    def test_crawl
      result = @rss.crawl
      assert_true(File.exist?(result[:cache_path]))
      assert_true(File.exist?(result[:digest_path]))
    end

    def test_to_s
      assert_true(@rss.to_s.present?)
    end
  end
end
