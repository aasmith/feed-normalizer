require 'rss'

module FeedNormalizer
  class RubyRssParser < Parser

    def self.parser
      RSS::Parser
    end

    def self.parse(xml)
      begin
        rss = parser.parse(xml)
      rescue Exception => e
        puts "Parser #{parser} failed because #{e.message.gsub("\n",', ')}"
        return nil
      end

      package(rss)
    end

    # Fairly high priority; a fast and strict parser.
    def self.priority
      100
    end

    protected

    def self.package(rss)
      feed = Feed.new

      # channel elements
      feed_mapping = {
        :generator => :generator,
        :title => :title,
        :urls => :link,
        :description => :description,
        :copyright => :copyright,
        :authors => :managingEditor,
        :last_updated => [:lastBuildDate, :pubDate]
      }

      map_functions!(feed_mapping, rss.channel, feed)

      # custom channel elements
      feed.id = "#{rss.channel.link}"
      feed.image = (rss.channel.image ? rss.channel.image.url : nil)

      # item elements
      item_mapping = {
        :date_published => :pubDate,
        :urls => :link,
        :description => :description,
        :title => :title,
        :authors => :author
      }

      rss.channel.items.each do |rss_item|
        feed_entry = Entry.new
        map_functions!(item_mapping, rss_item, feed_entry)

        # custom item elements
        feed_entry.id = rss_item.guid.content
        feed_entry.content.body = rss_item.description
        feed_entry.copyright = rss.channel.copyright

        feed.entries << feed_entry
      end

      feed
    end

  end
end

