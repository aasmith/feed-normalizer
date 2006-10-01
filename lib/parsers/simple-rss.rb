require File.dirname(__FILE__) + '/../../vendor/simple-rss/lib/simple-rss'

module FeedNormalizer

  # The SimpleRSS parser can handle both RSS and Atom feeds.
  class SimpleRssParser < Parser

    def self.parser
      SimpleRSS
    end

    def self.parse(xml)
      begin
        atomrss = parser.parse(xml)
      rescue Exception => e
        puts "Parser #{parser} failed because #{e.message.gsub("\n",', ')}"
        return nil
      end

      package(atomrss)
    end

    # Fairly low priority; a slower, liberal parser.
    def self.priority
      900
    end

    protected

    def self.package(atomrss)
      feed = Feed.new

      # channel elements
      feed_mapping = {
        :generator => :generator,
        :title => :title,
        :last_updated => [:updated, :lastBuildDate, :pubDate],
        :copyright => [:copyright, :rights],
        :authors => [:author, :webMaster, :managingEditor, :contributor],
        :urls => :link,
        :description => [:description, :subtitle]
      }

      map_functions!(feed_mapping, atomrss, feed)

      # custom channel elements
      feed.id = atomrss.id == atomrss.object_id ? "#{atomrss.link}[#{(atomrss.lastBuildDate || atomrss.pubDate).to_i}]" : atomrss.id
      feed.image = image(atomrss)

      feed
    end

    # sets value, or appends to an existing value
    def self.map_functions!(mapping, src, dest)

      mapping.each do |dest_function, src_functions|
        src_functions = [src_functions].flatten # pack into array

        src_functions.each do |src_function|
          if src.respond_to? src_function
            value = src.send(src_function)
            append_or_set!(value, dest, dest_function) if value
          end
        end

      end
    end

    def self.append_or_set!(value, object, object_function)
      if object.send(object_function).respond_to? :push
        object.send(object_function).push(value)
      else
        object.send(:"#{object_function}=", value)
      end
    end

    def self.image(parser)
      if parser.respond_to?(:image) && parser.image
        if parser.image.match /<url>/ # RSS image contains an <url> spec
          parser.image.scan(/<url>(.*)<\/url>/).to_s
        else
          parser.image # Atom contains just the url
        end
      elsif parser.respond_to?(:logo) && parser.logo
        parser.logo
      end
    end

  end
end

