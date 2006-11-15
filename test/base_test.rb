$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'feed-normalizer'

include FeedNormalizer

class BaseTest < Test::Unit::TestCase

  XML_FILES = {}

  data_dir = File.dirname(__FILE__) + '/data'

  # Load up the xml files
  Dir.open(data_dir).each do |fn|
    next unless fn =~ /[.]xml$/
    XML_FILES[fn.scan(/(.*)[.]/).to_s.to_sym] = File.read(data_dir + "/#{fn}")
  end

  def test_basic_parse
    assert_kind_of Feed, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20])
  end

  def test_force_parser
    assert_kind_of Feed, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20],
      :force_parser => RubyRssParser, :try_others => true)
  end

  def test_force_parser_exclusive
    assert_kind_of Feed, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20],
      :force_parser => RubyRssParser, :try_others => false)
  end

  def test_ruby_rss_parser
    assert_kind_of Feed, feed=FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20],
      :force_parser => RubyRssParser, :try_others => false)
    assert_kind_of Feed, feed=FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rdf10],
      :force_parser => RubyRssParser, :try_others => false)
  end

  def test_simple_rss_parser
    assert_kind_of Feed, feed=FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20],
      :force_parser => SimpleRssParser, :try_others => false)
    assert_kind_of Feed, feed=FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10],
      :force_parser => SimpleRssParser, :try_others => false)
  end

  def test_parser_failover_order
    assert_equal SimpleRSS, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10], :force_parser => RubyRssParser).parser
  end

  def test_force_parser_fail
    assert_nil FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10], :force_parser => RubyRssParser, :try_others => false)
  end

  def test_all_parsers_fail
    assert_nil FeedNormalizer::FeedNormalizer.parse("This isn't RSS or Atom!")
  end

  def test_correct_parser_used
    assert_equal RSS::Parser, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20]).parser
    assert_equal SimpleRSS, FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10]).parser
  end

  def test_rss
    feed = FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20])

    assert_equal "BBC News | Technology | UK Edition", feed.title
    assert_equal ["http://news.bbc.co.uk/go/rss/-/1/hi/technology/default.stm"], feed.urls
    assert_equal "MP3 player court order overturned", feed.entries.last.title
    assert_equal "SanDisk puts its MP3 players back on display at a German electronics show after overturning a court injunction.", feed.entries.last.description
    assert_equal "SanDisk puts its MP3 players back on display at a German electronics show after overturning a court injunction.", feed.entries.last.content
  end

  def test_simplerss
    feed = FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10])

    assert_equal "~:caboose", feed.title
    assert_equal "http://habtm.com/xml/atom10/feed.xml", feed.url
    assert_equal "Starfish - Easy Distribution of Site Maintenance", feed.entries.last.title
    assert_equal "urn:uuid:6c028f36-f87a-4f53-b7e3-1f943d2341f0", feed.entries.last.id

    assert !feed.entries.last.description.include?("google fame")
    assert feed.entries.last.content.include?("google fame")
  end

  def test_sanity_check
    XML_FILES.keys.each do |xml_file|
      feed = FeedNormalizer::FeedNormalizer.parse(XML_FILES[xml_file])

      assert [feed.title, feed.url, feed.entries.first.url].collect{|e| e.is_a?(String)}.all?, "Not everything was a String in #{xml_file}"
      assert [feed.parser, feed.class].collect{|e| e.is_a?(Class)}.all?
    end
  end

  def test_feed_equality
    assert_equal FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20]), FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20])
    assert_equal FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10]), FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10])
    assert_not_equal FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom03]), FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10])
    assert_not_equal FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20]), FeedNormalizer::FeedNormalizer.parse(XML_FILES[:atom10])
    assert_not_equal FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20]), FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20diff])

    XML_FILES.keys.each do |xml_file|
      feed = FeedNormalizer::FeedNormalizer.parse(XML_FILES[xml_file])
      assert_equal feed, Marshal.load(Marshal.dump(feed))
    end
  end

  def test_feed_diff
    feed = FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20])

    diff = feed.diff(FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20diff]))
    diff_short = feed.diff(FeedNormalizer::FeedNormalizer.parse(XML_FILES[:rss20diff_short]))
    no_diff = feed.diff(feed)

    assert diff.keys.all? {|key| [:title, :items].include?(key)}
    assert_equal 2, diff[:items].size

    assert diff_short.keys.all? {|key| [:title, :items].include?(key)}
    assert_equal [3,2], diff_short[:items]

    assert no_diff.empty?
  end

  def test_unescape
    assert_equal "' ' &deg;", HtmlCleaner.unescapeHTML("&apos; &#39; &deg;")
    assert_equal "\" &deg;", HtmlCleaner.unescapeHTML("&quot; &deg;")
    assert_equal "heavily subnet&#8217;d network,", HtmlCleaner.unescapeHTML("heavily subnet&#8217;d network,")
  end

  def test_add_entities
    assert_equal "x &gt; y", HtmlCleaner.add_entities("x > y")
    assert_equal "1 &amp; 2", HtmlCleaner.add_entities("1 & 2")
    assert_equal "&amp; &#123; &acute; &#x123;", HtmlCleaner.add_entities("& &#123; &acute; &#x123;")
    assert_equal "&amp; &#123; &ACUTE; &#X123A; &#x80f;", HtmlCleaner.add_entities("& &#123; &ACUTE; &#X123A; &#x80f;")
    assert_equal "heavily subnet&#8217;d network,", HtmlCleaner.add_entities("heavily subnet&#8217;d network,")
  end

  def test_html_clean
    assert_equal "", HtmlCleaner.clean("")

    assert_equal "<p>foo &gt; *</p>", HtmlCleaner.clean("<p>foo > *</p>")
    assert_equal "<p>foo &gt; *</p>", HtmlCleaner.clean("<p>foo &gt; *</p>")

    assert_equal "<p>para</p>", HtmlCleaner.clean("<p foo=bar>para</p>")

    assert_equal "<p>para</p>", HtmlCleaner.clean("<p>para</p></notvalid>")
    assert_equal "<p>para</p>", HtmlCleaner.clean("<p>para</p></body>")

    assert_equal "<p>para</p>", HtmlCleaner.clean("<p>para</p><plaintext>")
    assert_equal "<p>para</p>", HtmlCleaner.clean("<p>para</p><object><param></param></object>")
    assert_equal "<p>para</p>", HtmlCleaner.clean("<p>para</p><iframe src='http://evil.example.org'></iframe>")
    assert_equal "<p>para</p>", HtmlCleaner.clean("<p>para</p><iframe src='http://evil.example.org'>")

    assert_equal "<p>para</p>", HtmlCleaner.clean("<p>para</p><invalid>invalid</invalid>")

    assert_equal "<a href=\"http://example.org\">para</a>", HtmlCleaner.clean("<a href='http://example.org'>para</a>")
    assert_equal "<a href=\"http://example.org/proc?a&amp;b\">para</a>", HtmlCleaner.clean("<a href='http://example.org/proc?a&b'>para</a>")

    assert_equal "<p>two</p>", HtmlCleaner.clean("<p>para</p><body><p>two</p></body>")
    assert_equal "<p>two</p>", HtmlCleaner.clean("<p>para</p><body><p>two</p>")
    assert_equal "<p>para</p>&lt;bo /dy&gt;<p>two</p>", HtmlCleaner.clean("<p>para</p><bo /dy><p>two</p></body>")
    assert_equal "<p>para</p>&lt;bo\\/dy&gt;<p>two</p>", HtmlCleaner.clean("<p>para</p><bo\\/dy><p>two</p></body>")
    assert_equal "<p>para</p><p>two</p>", HtmlCleaner.clean("<p>para</p><body/><p>two</p></body>")

    assert_equal "<p>one &amp; two</p>", HtmlCleaner.clean(HtmlCleaner.clean("<p>one & two</p>"))

    assert_equal "<p id=\"p\">para</p>", HtmlCleaner.clean("<p id=\"p\" ignore=\"this\">para</p>")
    assert_equal "<p id=\"p\">para</p>", HtmlCleaner.clean("<p id=\"p\" onclick=\"this\">para</p>")

    assert_equal "<img src=\"http://example.org/pic\" />", HtmlCleaner.clean("<img src=\"http://example.org/pic\" />")
    assert_equal "<img />", HtmlCleaner.clean("<img src=\"jav a script:call()\" />")

    assert_equal "what's new", HtmlCleaner.clean("what&#000039;s new")
    assert_equal "&quot;what's new?&quot;", HtmlCleaner.clean("\"what&apos;s new?\"")
    assert_equal "&quot;what's new?&quot;", HtmlCleaner.clean("&quot;what&apos;s new?&quot;")

    # Real-world examples from selected feeds
    assert_equal "I have a heavily subnet&#8217;d/vlan&#8217;d network,", HtmlCleaner.clean("I have a heavily subnet&#8217;d/vlan&#8217;d network,")

    assert_equal "<pre><blockquote>&lt;%= start_form_tag :action =&gt; &quot;create&quot; %&gt;</blockquote></pre>",
                 HtmlCleaner.clean("<pre><blockquote>&lt;%= start_form_tag :action => \"create\" %></blockquote></pre>")

    assert_equal "<a href=\"http://www.mcall.com/news/local/all-smashedmachine1107-cn,0,1574203.story?coll=all-news-hed\">[link]</a><a href=\"http://reddit.com/info/pyhc/comments\">[more]</a>",
                 HtmlCleaner.clean("&lt;a href=\"http://www.mcall.com/news/local/all-smashedmachine1107-cn,0,1574203.story?coll=all-news-hed\"&gt;[link]&lt;/a&gt;&lt;a href=\"http://reddit.com/info/pyhc/comments\"&gt;[more]&lt;/a&gt;")


    # Various exploits from the past
    assert_equal "", HtmlCleaner.clean("<_img foo=\"<IFRAME width='80%' height='400' src='http://alive.znep.com/~marcs/passport/grabit.html'></IFRAME>\" >")
    assert_equal "<a href=\"https://bugzilla.mozilla.org/attachment.cgi?id=&amp;action=force_internal_error&lt;script&gt;alert(document.cookie)&lt;/script&gt;\">link</a>",
                 HtmlCleaner.clean("<a href=\"https://bugzilla.mozilla.org/attachment.cgi?id=&action=force_internal_error<script>alert(document.cookie)</script>\">link</a>")
    assert_equal "<img src=\"doesntexist.jpg\" />", HtmlCleaner.clean("<img src='doesntexist.jpg' onerror='alert(document.cookie)'/>")

    # This doesnt come out as I would like, because hpricot sees things differently, but the result is still safe.
    assert HtmlCleaner.clean("<p onclick!\#$%&()*~+-_.,:;?@[/|\\]^=alert(\"XSS\")>para</p>") !~ /\<\>/

    # TODO: Must remove comments from the parse tree
    #assert_equal "", HtmlCleaner.clean("<!--[if gte IE 4]><SCRIPT>alert('XSS');</SCRIPT><![endif]-->")
  end

  def test_html_flatten
    assert_equal "", HtmlCleaner.flatten("")

    assert_equal "hello", HtmlCleaner.flatten("hello")
    assert_equal "hello world", HtmlCleaner.flatten("hello\nworld")

    assert_equal "A &gt; B : C", HtmlCleaner.flatten("A > B : C")
    assert_equal "what's new", HtmlCleaner.flatten("what&#39;s new")
    assert_equal "&quot;what's new?&quot;", HtmlCleaner.flatten("\"what&apos;s new?\"")

    assert_equal "we&#8217;ve got &lt;a hre", HtmlCleaner.flatten("we&#8217;ve got <a hre")

    assert_equal "http://example.org", HtmlCleaner.flatten("http://example.org")
    assert_equal "http://example.org/proc?a&amp;b", HtmlCleaner.flatten("http://example.org/proc?a&b")

    assert_equal "&quot;what's new?&quot;", HtmlCleaner.flatten(HtmlCleaner.flatten("\"what&apos;s new?\""))
  end

  def test_dodgy_uri
    # All of these javascript urls work in IE6.
    assert HtmlCleaner.dodgy_uri?("javascript:alert('HI');")
    assert HtmlCleaner.dodgy_uri?(" &#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116; \n :alert('HI');")
    assert HtmlCleaner.dodgy_uri?("JaVaScRiPt:alert('HI');")
    assert HtmlCleaner.dodgy_uri?("JaV   \naSc\nRiPt:alert('HI');")

    # entities lacking ending ';'
    # This only works if they're all packed together without spacing.
    assert HtmlCleaner.dodgy_uri?("&#106&#97&#118&#97&#115&#99&#114&#105&#112&#116&#58&#97&#108&#101&#114&#116&#40&#39&#105&#109&#103&#45&#111&#98&#45&#50&#39&#41")
    assert HtmlCleaner.dodgy_uri?("&#106&#97&#118&#97&#115&#99&#114&#105&#112&#116&#58&#97&#108&#101&#114&#116&#40&#39&#105&#109&#103&#45&#111&#98&#45&#50&#39 &#41 ; ")
    # catch extra spacing anyway.. support for this is possible, depending where the spaces are.
    assert HtmlCleaner.dodgy_uri?("&#106 &#97 &#118 &#97 &#115 &#99 &#114 &#105 &#112 &#116 &#58 &#97 &#108 &#101 &#114 &#116 &#40 &#39 &#105 &#109 &#103 &#45 &#111 &#98 &#45 &#50 &#39 &#41 ; ")

    # url-encoded
    assert HtmlCleaner.dodgy_uri?("%6A%61%76%61%73%63%72%69%70%74%3A%61%6C%65%72%74%28%27%69%6D%67%2D%6F%62%2D%33%27%29")

    # Other evil schemes
    assert HtmlCleaner.dodgy_uri?("vbscript:MsgBox(\"hi\")")
    assert HtmlCleaner.dodgy_uri?("mocha:alert('hi')")
    assert HtmlCleaner.dodgy_uri?("livescript:alert('hi')")
    assert HtmlCleaner.dodgy_uri?("data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K")

    # Various non-printing chars
    assert HtmlCleaner.dodgy_uri?("javas\0cript:foo()")
    assert HtmlCleaner.dodgy_uri?(" &#14; javascript:foo()")
    assert HtmlCleaner.dodgy_uri?("jav&#x0A;ascript:foo()")
    assert HtmlCleaner.dodgy_uri?("jav&#x09;ascript:foo()")

    # The Good
    assert_nil HtmlCleaner.dodgy_uri?("http://example.org")
    assert_nil HtmlCleaner.dodgy_uri?("http://example.org/foo.html")
    assert_nil HtmlCleaner.dodgy_uri?("http://example.org/foo.cgi?x=y&a=b")
    assert_nil HtmlCleaner.dodgy_uri?("http://example.org/foo.cgi?x=y&amp;a=b")
    assert_nil HtmlCleaner.dodgy_uri?("http://example.org/foo.cgi?x=y&#38;a=b")
    assert_nil HtmlCleaner.dodgy_uri?("http://example.org/foo.cgi?x=y&#x56;a=b")
  end

end

