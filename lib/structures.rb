
module FeedNormalizer

  class Content
    TYPE = [:text, :html, :xhtml]
    attr_accessor :type, :body

    def initialize
      @type = :text
    end

    def to_s
      body
    end
  end

  class Entry
    ELEMENTS = [:content, :date_published, :urls, :description, :title, :id, :authors, :copyright]
    attr_accessor *ELEMENTS

    def initialize
      @urls = []
      @authors = []
      @content = Content.new
    end

    def url
      urls.first
    end
  end

  class Feed
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

    def url
      urls.first
    end
  end

end

