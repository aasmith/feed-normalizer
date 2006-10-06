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
        #puts "Parser #{parser} failed because #{e.message.gsub("\n",', ')}"
        return nil
      end

      rss ? package(rss) : nil
    end

    # Fairly high priority; a fast and strict parser.
    def self.priority
      100
    end

    protected

    def self.package(rss)
      feed = Feed.new(self)

      # channel elements
      feed_mapping = {
        :generator => :generator,
        :title => :title,
        :urls => :link,
        :description => :description,
        :copyright => :copyright,
        :authors => :managingEditor,
        :last_updated => [:lastBuildDate, :pubDate],
        :id => :guid
      }

      # make two passes, to catch all possible root elements
      map_functions!(feed_mapping, rss, feed)
      map_functions!(feed_mapping, rss.channel, feed)

      # custom channel elements
      feed.image = rss.image ? rss.image.url : nil

      # item elements
      item_mapping = {
        :date_published => :pubDate,
        :urls => :link,
        :description => :description,
        :title => :title,
        :authors => :author
      }

      rss.items.each do |rss_item|
        feed_entry = Entry.new
        map_functions!(item_mapping, rss_item, feed_entry)

        # custom item elements
        feed_entry.id = rss_item.guid.content if rss_item.respond_to? :guid
        feed_entry.content.body = rss_item.description
        feed_entry.copyright = rss.copyright if rss_item.respond_to? :copyright

        feed.entries << feed_entry
      end

      feed
    end

  end
end

