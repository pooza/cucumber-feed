module CucumberFeed
  class FeedRendererTest < Test::Unit::TestCase
    def test_all
      FeedRenderer.all do |feed|
        assert(feed.is_a?(FeedRenderer))
      end
    end
  end
end
