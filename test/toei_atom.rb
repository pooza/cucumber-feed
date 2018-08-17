require 'cucumber-feed/slack'
require 'cucumber-feed/atom/toei'

module CucumberFeed
  class ToeiAtomTest < Test::Unit::TestCase
    def setup
      @atom = ToeiAtom.new
    end

    def test_crawl
      result = @atom.crawl
      assert_true(File.exist?(result[:cache_path]))
      assert_true(File.exist?(result[:digest_path]))
    end

    def test_to_s
      assert_true(@atom.to_s.present?)
    end
  end
end
