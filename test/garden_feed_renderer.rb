require 'cucumber-feed/renderer/garden_feed'

module CucumberFeed
  class GardenFeedRendererTest < Test::Unit::TestCase
    def setup
      @rss = GardenFeedRenderer.new
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
