
module FeedNormalizer
  class BogoParser < Parser

    def self.parser
      nil
    end

    def self.parse(xml)
      nil
    end

    # Low priority; crap and slow parser.
    def self.priority
      100000
    end

  end
end
