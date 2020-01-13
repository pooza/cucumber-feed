module CucumberFeed
  class FeedRendererTest < Test::Unit::TestCase
    def test_all
      FeedRenderer.all do |feed|
        assert_kind_of(FeedRenderer, feed)
      end
    end
  end
end
