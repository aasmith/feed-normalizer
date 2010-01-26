(in /usr/home/andy/dev/feed-normalizer)
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{feed-normalizer}
  s.version = "1.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew A. Smith"]
  s.date = %q{2010-01-25}
  s.description = %q{An extensible Ruby wrapper for Atom and RSS parsers.

Feed normalizer wraps various RSS and Atom parsers, and returns a single unified
object graph, regardless of the underlying feed format.}
  s.email = %q{andy@tinnedfruit.org}
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "Rakefile", "README.txt", "feed-normalizer.gemspec", "lib/feed-normalizer.rb", "lib/html-cleaner.rb", "lib/parsers/rss.rb", "lib/parsers/simple-rss.rb", "lib/structures.rb", "test/data/atom03.xml", "test/data/atom10.xml", "test/data/rdf10.xml", "test/data/rss20.xml", "test/data/rss20diff.xml", "test/data/rss20diff_short.xml", "test/test_feednormalizer.rb", "test/test_htmlcleaner.rb"]
  s.homepage = %q{http://github.com/aasmith/feed-normalizer}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{feed-normalizer}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Extensible Ruby wrapper for Atom and RSS parsers}
  s.test_files = ["test/test_feednormalizer.rb", "test/test_htmlcleaner.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<simple-rss>, [">= 1.1"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0.6"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.3"])
      s.add_development_dependency(%q<gemcutter>, [">= 0.3.0"])
      s.add_development_dependency(%q<hoe>, [">= 2.5.0"])
    else
      s.add_dependency(%q<simple-rss>, [">= 1.1"])
      s.add_dependency(%q<hpricot>, [">= 0.6"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.3"])
      s.add_dependency(%q<gemcutter>, [">= 0.3.0"])
      s.add_dependency(%q<hoe>, [">= 2.5.0"])
    end
  else
    s.add_dependency(%q<simple-rss>, [">= 1.1"])
    s.add_dependency(%q<hpricot>, [">= 0.6"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.3"])
    s.add_dependency(%q<gemcutter>, [">= 0.3.0"])
    s.add_dependency(%q<hoe>, [">= 2.5.0"])
  end
end
