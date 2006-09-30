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
      rss_to_feed = {
        :generator => :generator,
        :title => :title,
        :link => :urls,
        :description => :description,
        :copyright => :copyright,
        :managingEditor => :authors
      }

      map_functions!(rss_to_feed, rss.channel, feed)

      # custom channel elements
      feed.id = "#{rss.channel.link}[#{(rss.channel.lastBuildDate || rss.channel.pubDate).to_i}]"
      feed.last_updated = (rss.channel.lastBuildDate || rss.channel.pubDate)
      feed.image = (rss.channel.image ? rss.channel.image.url : nil)

      # item elements
      rss_item_to_feed_entry = {
        :pubDate => :date_published,
        :link => :urls,
        :description => :description,
        :title => :title,
        :author => :authors
      }

      rss.channel.items.each do |rss_item|
        feed_entry = Entry.new
        map_functions!(rss_item_to_feed_entry, rss_item, feed_entry)

        # custom item elements
        feed_entry.id = rss_item.guid.content
        feed_entry.content.body = rss_item.description
        feed_entry.copyright = rss.channel.copyright

        feed.entries << feed_entry
      end

      feed
    end

    # sets value, or appends to an existing value
    def self.map_functions!(src_dest_map, src, dest)
      src_dest_map.each do |src_function, dest_function|
        if dest.send(dest_function).respond_to? :<<
          dest.send(dest_function) << src.send(src_function)
        else
          dest.send(:"#{dest_function}=", src.send(src_function))
        end
      end
    end

  end
end

