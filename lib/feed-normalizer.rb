require 'structures'

module FeedNormalizer
  VERSION = "1.0"


  # The root parser object. Every parser must extend this object.
  class Parser

    # Parser being used.
    def self.parser
      nil
    end

    # Parses the given feed, and returns a normalized representation.
    # Returns nil if the feed could not be parsed.
    def self.parse(feed)
      nil
    end

    # Returns a number to indicate parser priority.
    # The lower the number, the more likely the parser will be used first,
    # and vice-versa.
    def self.priority
      0
    end

    protected

    # Some utility methods that can be used by subclasses.

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

    private

    # Callback that ensures that every parser gets registered.
    def self.inherited(subclass)
      ParserRegistry.register(subclass)
    end

  end


  # The parser registry keeps a list of current parsers that are available.
  class ParserRegistry

    @@parsers = []

    def self.register(parser)
      @@parsers << parser
    end

    def self.parsers
      @@parsers.sort_by { |parser| parser.priority }
    end

  end


  class FeedNormalizer

    # Parses the given xml and attempts to return a normalized Feed object.
    # Setting forced parser to a suitable parser will mean that parser is
    # used first, and if try_others is false, it is the only parser used,
    # otherwise all parsers in the ParserRegistry are attempted next, in
    # order of priority.
    def self.parse(xml, forced_parser=nil, try_others=false)

      if forced_parser
        result = forced_parser.parse(xml)

        if result
          return result
        elsif !try_others
          return nil
        else
          # fall through and continue with other parsers
        end
      end

      ParserRegistry.parsers.each do |parser|
        result = parser.parse(xml)
        break result if result
      end

    end
  end


  parser_dir = File.dirname(__FILE__) + '/parsers'

  # Load up the parsers
  Dir.open(parser_dir).each do |fn|
    next unless fn =~ /[.]rb$/
    require parser_dir + "/#{fn}"
  end

end

