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
    assert_kind_of Feed, feed=FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10], SimpleRssParser, false)
  end

  # Attempts to parse a feed that Ruby's RSS can't handle.
  # SimpleRSS should provide the parsed feed.
  def test_parser_failover_order
    assert_kind_of Feed, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10])
  end

  def test_all_parsers_fail
    assert_nil FeedNormalizer::FeedNormalizer.parse("This isn't RSS or Atom!")
  end

  def test_correct_parser_used
    assert_equal RSS::Parser, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20]).parser
    assert_equal SimpleRSS, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10]).parser
  end

  def test_sanity_check
    XML_FILES.keys.each do |xml_file|
      feed = FeedNormalizer::FeedNormalizer.parse(XML_FILES[xml_file])

      assert [feed.title, feed.url, feed.entries.first.url].collect{|e| e.is_a?(String)}.all?, "Not everything was a String"
      assert [feed.parser, feed.class].collect{|e| e.is_a?(Class)}.all?
    end
  end

  def test_feed_equality
    assert_equal FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20]), FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20])
    assert_equal FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10]), FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10])
    assert_not_equal FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom03]), FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10])
    assert_not_equal FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20]), FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10])

    XML_FILES.keys.each do |xml_file|
      feed = FeedNormalizer::FeedNormalizer.parse(XML_FILES[xml_file])
      assert_equal feed, Marshal.load(Marshal.dump(feed))
    end

  end

end
