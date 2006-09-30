
module FeedNormalizer

  class Content
    TYPE = [:text, :html, :xhtml]
    attr_accessor :type, :body

    def initialize
      self.type = :text
    end

    def to_s
      body
    end
  end

  class Entry
    ELEMENTS = [:content, :date_published, :urls, :description, :title, :id, :authors, :copyright]
    attr_accessor *ELEMENTS

    def initialize
      self.urls = []
      self.authors = []
      self.content = Content.new
    end

    def url
      urls.first
    end
  end

  class Feed
    ELEMENTS = [:title, :description, :id, :last_updated, :copyright, :authors, :urls, :image, :generator, :items]
    attr_accessor *ELEMENTS

    alias :entries :items

    def initialize
      # set up associations (i.e. arrays where needed)
      self.urls = []
      self.authors = []
      self.items = []
    end

    def channel() self end

    def url
      urls.first
    end
  end

end

