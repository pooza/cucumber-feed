require 'cucumber-feed/renderer/garden_feed'

module CucumberFeed
  class GardenFeedRendererTest < Test::Unit::TestCase
    def setup
      @renderer = GardenFeedRenderer.new
    end

    def test_crawl
      result = @renderer.crawl
      assert_true(File.exist?(result[:atom]))
      assert_true(File.exist?(result[:rss]))
      assert_true(File.exist?(result[:digest]))
    end

    def test_render
      assert_true(@renderer.render(:rss).present?)
      assert_true(@renderer.render(:atom).present?)
    end
  end
end
