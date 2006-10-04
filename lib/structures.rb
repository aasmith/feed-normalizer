
module FeedNormalizer

  module Singular

    # If the method being called is a singular (in this simple case, does not
    # end with an 's'), then it calls the plural method, and calls the first
    # element. We're assuming that plural methods provide an array.
    #
    # Example:
    # Object contains an array called 'alphas', which looks like [:a, :b, :c].
    # Call object.alpha and :a is returned.
    def method_missing(name)
      if name.to_s =~ /[^s]$/ # doesnt end with 's'
        plural = :"#{name}s"
        if self.respond_to?(plural)
          return self.send(plural).first
        end
      end
      nil
    end

  end

  module ElementEquality

    def eql?(other)
      self == (other)
    end

    def ==(other)
      other.equal?(self) ||
        (other.instance_of?(self.class) &&
          self.class::ELEMENTS.collect{|el| self.instance_variable_get("@#{el}")==other.instance_variable_get("@#{el}")}.all?)
    end

  end

  # Wraps content used in an Entry. type defaults to :text.
  class Content
    TYPE = [:text, :html, :xhtml]
    attr_accessor :type, :body

    def initialize
      @type = :text
    end

    def to_s
      body
    end

    def eql?(other)
      self == (other)
    end

    # Equal if the body is the same. Ignores type.
    def ==(other)
      other.equal?(self) ||
        (other.instance_of?(self.class) &&
          self.body == other.body)
    end
  end

  # Represents a feed item entry.
  class Entry
    include Singular, ElementEquality

    ELEMENTS = [:content, :date_published, :urls, :description, :title, :id, :authors, :copyright]
    attr_accessor *ELEMENTS

    def initialize
      @urls = []
      @authors = []
      @content = Content.new
    end

  end

  # Represents the root element of a feed.
  class Feed
    include Singular, ElementEquality

    ELEMENTS = [:title, :description, :id, :last_updated, :copyright, :authors, :urls, :image, :generator, :items]
    attr_accessor *ELEMENTS
    attr_accessor :parser

    alias :entries :items

    def initialize(wrapper)
      # set up associations (i.e. arrays where needed)
      @urls = []
      @authors = []
      @items = []
      @parser = wrapper.parser
    end

    def channel() self end
  end

end

