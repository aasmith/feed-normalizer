Gem::Specification.new do |s|
  s.name = %q{feed-normalizer}
  s.version = "1.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew A. Smith"]
  s.date = %q{2008-10-10}
  s.description = %q{An extensible Ruby wrapper for Atom and RSS parsers.  Feed normalizer wraps various RSS and Atom parsers, and returns a single unified object graph, regardless of the underlying feed format.}
  s.email = %q{andy@tinnedfruit.org}
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "Rakefile", "README.txt", "lib/feed-normalizer.rb", "lib/html-cleaner.rb", "lib/parsers/rss.rb", "lib/parsers/simple-rss.rb", "lib/structures.rb", "test/data/atom03.xml", "test/data/atom10.xml", "test/data/rdf10.xml", "test/data/rss20.xml", "test/data/rss20diff.xml", "test/data/rss20diff_short.xml", "test/test_all.rb", "test/test_feednormalizer.rb", "test/test_htmlcleaner.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://feed-normalizer.rubyforge.org/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{feed-normalizer}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Extensible Ruby wrapper for Atom and RSS parsers}
  s.test_files = ["test/test_all.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<simple-rss>, [">= 1.1"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0.6"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<simple-rss>, [">= 1.1"])
      s.add_dependency(%q<hpricot>, [">= 0.6"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<simple-rss>, [">= 1.1"])
    s.add_dependency(%q<hpricot>, [">= 0.6"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
