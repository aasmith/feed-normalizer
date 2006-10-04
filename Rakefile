require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/clean'
require 'rake/gempackagetask'

PKG_FILES = FileList[
    "lib/**/*", "test/**/*", "[A-Z]*", "Rakefile", "html/**/*"
]

Gem::manage_gems

task :default => [:test]
task :package => [:test, :doc]

spec = Gem::Specification.new do |s|
  s.name = "feed-normalizer"
  s.version = "1.0.1"
  s.author = "Andrew A. Smith"
  s.email = "andy@tinnedfruit.org"
  s.homepage = "http://code.google.com/p/feed-normalizer/"
  s.platform = Gem::Platform::RUBY
  s.summary = "Extensible Ruby wrapper for Atom and RSS parsers"
  s.files =  PKG_FILES
  s.require_path = "lib"
  s.autorequire = "feed-normalizer"
  s.has_rdoc = true
  s.add_dependency  "simple-rss", ">= 1.1"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

desc "Create documentation"
Rake::RDocTask.new("doc") do |rdoc|
  rdoc.title = "Feed Normalizer"
  rdoc.rdoc_dir = 'doc'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

