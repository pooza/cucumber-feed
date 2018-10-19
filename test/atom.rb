require 'cucumber-feed/rss'

module CucumberFeed
  class RSSTest < Test::Unit::TestCase
    def test_all
      RSS.all do |rss|
        assert_true(rss.is_a?(RSS))
      end
    end
  end
end
