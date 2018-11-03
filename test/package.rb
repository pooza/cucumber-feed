module CucumberFeed
  class PackageTest < Test::Unit::TestCase
    def test_name
      assert_equal(Package.name, 'cucumber-feed')
    end
  end
end
