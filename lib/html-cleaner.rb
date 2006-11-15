require 'hpricot'
require 'cgi'

module FeedNormalizer

  # Various methods for cleaning up HTML and preparing it for safe public
  # consumption.
  #
  # Documents used for refrence:
  # - http://www.w3.org/TR/html4/index/attributes.html
  # - http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
  # - http://feedparser.org/docs/html-sanitization.html
  # - http://code.whytheluckystiff.net/hpricot/wiki
  class HtmlCleaner

    # allowed html elements.
    HTML_ELEMENTS = %w(
      a abbr acronym address area b bdo big blockquote br button caption center
      cite code col colgroup dd del dfn dir div dl dt em fieldset font h1 h2 h3
      h4 h5 h6 hr i img ins kbd label legend li map menu ol optgroup p pre q s
      samp small span strike strong sub sup table tbody td tfoot th thead tr tt
      u ul var
    )

    # allowed attributes.
    HTML_ATTRS = %w(
      abbr accept accept-charset accesskey align alt axis border cellpadding
      cellspacing char charoff charset checked cite class clear cols colspan
      color compact coords datetime dir disabled for frame headers height href
      hreflang hspace id ismap label lang longdesc maxlength media method
      multiple name nohref noshade nowrap readonly rel rev rows rowspan rules
      scope selected shape size span src start summary tabindex target title
      type usemap valign value vspace width
    )

    # allowed attributes, but they can contain URIs, extra caution required.
    # NOTE: That means this doesnt list *all* URI attrs, just the ones that are allowed.
    HTML_URI_ATTRS = %w(
      href src cite usemap longdesc
    )

    DODGY_URI_SCHEMES = %w(
      javascript vbscript mocha livescript data
    )

    class << self

      # Do this:
      # - unescape HTML
      # - parse HTML into tree
      # - find body if present, and extract tree inside that tag, otherwise parse whole tree
      # - for each tag
      #  - remove tag if not on list
      #  - else escape HTML tag contents ***
      #  - remove all attributes not on list
      #  - extra-scrub URI attrs - delete any attrs that begin with \s*javascript\s*:
      # - done...
      #
      # Extra (i.e. unmatched) ending tags are removed.
      def clean(str)
        str = unescapeHTML(str)

        doc = Hpricot(str, :xhtml_strict => true)
        doc = subtree(doc, :body)

        # get all the tags in the document
        tags = (doc/"*").collect {|e| e.name}

        # Remove tags that aren't whitelisted.
        remove_tags!(doc, tags - HTML_ELEMENTS)
        remaining_tags = tags & HTML_ELEMENTS

        # Remove attributes that aren't on the whitelist, or are suspicious URLs.
        (doc/remaining_tags.join(",")).each do |element|
          element.attributes.reject! do |attr,val|
            !HTML_ATTRS.include?(attr) || (HTML_URI_ATTRS.include?(attr) && dodgy_uri?(val))
          end

          element.attributes = element.attributes.build_hash {|a,v| [a, add_entities(v)]}
        end unless remaining_tags.empty?

        doc.traverse_text {|t| t.set(add_entities(t.to_s))}

        doc.to_s
      end

      # For all other feed elements:
      # - unescape HTML
      # - if there are no tags (<,>), escape HTML and return
      # - else parse HTML into tree (taking body as root, if present, as before)
      # - for each whitelisted tag
      #  - take contents, HTML escaped, build up string.
      # - return built up string.
      def flatten(str)
        str.gsub!("\n", " ")
        str = unescapeHTML(str)

        doc = Hpricot(str, :xhtml_strict => true)
        doc = subtree(doc, :body)

        out = ""
        doc.traverse_text {|t| out << add_entities(t.to_s)}

        return out
      end

      # Returns true if the given string contains a suspicious URL,
      # i.e. a javascript link.
      #
      # This method rejects javascript, vbscript, livescript, mocha and data URLs.
      # It *could* be refined to only deny dangerous data URLs, however.
      def dodgy_uri?(uri)

        # special case for consecutive poorly-formed entities
        # if these occur back-to-back, to back-to-back with only space between
        # them *anywhere* within the string, then throw it out.
        return true if (uri =~ /&\#(\d+|x[0-9a-f]+)[&\000-\037\177\s]+/mi)

        # Try escaping as both HTML or URI encodings, and then trying
        # each scheme regexp on each
        [unescapeHTML(uri), CGI.unescape(uri)].each do |unesc_uri|
          DODGY_URI_SCHEMES.each do |scheme|

            regexp = "#{scheme}:".gsub(/./) do |char|
              "([\000-\037\177\s]*)#{char}"
            end

            # regexp looks something like
            # /\A([\000-\037\177\s]*)j([\000-\037\177\s]*)a([\000-\037\177\s]*)v([\000-\037\177\s]*)a([\000-\037\177\s]*)s([\000-\037\177\s]*)c([\000-\037\177\s]*)r([\000-\037\177\s]*)i([\000-\037\177\s]*)p([\000-\037\177\s]*)t([\000-\037\177\s]*):/mi
            return true if (unesc_uri =~ %r{\A#{regexp}}mi)
          end
        end

        nil
      end

      # unescape's HTML. If xml is true, also converts XML-only named entities to HTML.
      def unescapeHTML(str, xml = true)
        CGI.unescapeHTML(xml ? str.gsub("&apos;", "&#39;") : str)
      end

      # Adds entities where possible.
      # Works like CGI.escapeHTML, but will not escape existing entities;
      # i.e. &#123; will NOT become &amp;#123;
      #
      # This method could be improved by adding a whitelist of html entities.
      def add_entities(str)
        str.gsub(/\"/n, '&quot;').gsub(/>/n, '&gt;').gsub(/</n, '&lt;').gsub(/&(?!(\#\d+|\#x([0-9a-f]+)|\w{2,8});)/nmi, '&amp;')
      end

      private

      # Everything below elment, or the just return the doc if element not present.
      def subtree(doc, element)
        doc.at("//#{element}/*") || doc
      end

      def remove_tags!(doc, tags)
        (doc/tags.join(",")).remove unless tags.empty?
      end

    end
  end
end


module Enumerable
  def build_hash
    result = {}
    self.each do |elt|
      key, value = yield elt
      result[key] = value
    end
    result
  end
end

# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/207625
# Subject: A simple Hpricot text setter
# From: Chris Gehlker <canyonrat mac.com>
# Date: Fri, 11 Aug 2006 03:19:13 +0900
class Hpricot::Text
  def set(string)
    @content = string
    self.raw_string = string
  end
end

