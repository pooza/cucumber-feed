require 'cucumber-feed/atom'

module CucumberFeed
  class AtomTest < Test::Unit::TestCase
    def test_all
      Atom.all do |atom|
        assert_true(atom.is_a?(Atom))
      end
    end
  end
end
