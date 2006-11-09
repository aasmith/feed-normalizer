
module FeedNormalizer

  module Singular

    # If the method being called is a singular (in this simple case, does not
    # end with an 's'), then it calls the plural method, and calls the first
    # element. We're assuming that plural methods provide an array.
    #
    # Example:
    # Object contains an array called 'alphas', which looks like [:a, :b, :c].
    # Call object.alpha and :a is returned.
    def method_missing(name, *args)
      return self.send(:"#{name}s").first rescue nil
    end

    def respond_to?(x, y=false)
      self.class::ELEMENTS.include?(x) || self.class::ELEMENTS.include?(:"#{x}s") || super(x, y)
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

    # Returns the difference between two Feed instances as a hash.
    # Any top-level differences in the Feed object as presented as:
    #
    #  { :title => [content, other_content] }
    #
    # For differences at the items level, an array of hashes shows the diffs
    # on a per-entry basis. Only entries that differ will contain a hash:
    #
    # { :items => [
    #     {:title=>["An article tile", "A new article title"]},
    #     {:title=>["one title", "a different title"]} ]}
    #
    # If the number of items in each feed are different, then the count of each
    # is provided instead:
    #
    # { :items => [4,5] }
    #
    # This method can also be useful for human-readable feed comparison if
    # its output is dumped to YAML.
    def diff(other, elements = self.class::ELEMENTS)
      diffs = {}

      elements.each do |element|
        if other.respond_to?(element)
          self_value = self.send(element)
          other_value = other.send(element)

          next if self_value == other_value

          diffs[element] = if other_value.respond_to?(:diff)
            self_value.diff(other_value)

          elsif other_value.is_a?(Enumerable) && other_value.all?{|v| v.respond_to?(:diff)}

            if self_value.size != other_value.size
              [self_value.size, other_value.size]
            else
              enum_diffs = []
              self_value.each_with_index do |val, index|
                enum_diffs << val.diff(other_value[index], val.class::ELEMENTS)
              end
              enum_diffs.reject{|h| h.empty?}
            end

          else
            [other_value, self_value] unless other_value == self_value
          end
        end
      end

      diffs
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

