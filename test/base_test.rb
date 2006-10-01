$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'feed-normalizer'

include FeedNormalizer

class BaseTest < Test::Unit::TestCase

  XML_FILES = {}

  def setup
    data_dir = File.dirname(__FILE__) + '/data'

    # Load up the xml files
    Dir.open(data_dir).each do |fn|
      next unless fn =~ /[.]xml$/
      XML_FILES[fn.scan(/(.*)[.]/).to_s.to_sym] = File.read(data_dir + "/#{fn}")
    end
  end


  def test_basic_parse
    assert_kind_of Feed, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20])
  end

  def test_force_parser
    assert_kind_of Feed, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20], RubyRssParser, true)
  end

  def test_force_parser_exclusive
    assert_kind_of Feed, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20], RubyRssParser, false)
  end

  def test_ruby_rss_parser
    assert_kind_of Feed, feed=FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20], RubyRssParser, false)
  end

  def test_simple_rss_parser
    assert_kind_of Feed, feed=FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20], SimpleRssParser, false)
    require 'pp'; pp feed
    assert_kind_of Feed, feed=FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10], SimpleRssParser, false)
    require 'pp'; pp feed
  end

  # Attempts to parse a feed that Ruby's RSS can't handle.
  # SimpleRSS should provide the parsed feed.
  def test_parser_failover_order

  end

end
