# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_content_highlightable/version'

Gem::Specification.new do |gem|
  gem.name          = "acts_as_content_highlightable"
  gem.version       = ActsAsContentHighlightable::VERSION
  gem.authors       = ["Karthik Ravichandran"]
  gem.email         = ["kb1990@gmail.com"]
  gem.summary       = %q{One way to highlight HTML content with Rails + Javascript.}
  gem.description   = %q{By tagging all the text nodes in the HTML content, this gem enables highlighting text and saving those highlights with user information}
  gem.homepage      = "https://github.com/kbravi/acts_as_content_highlightable"
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|gem|features)/})
  end
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency "nokogiri"

  gem.add_development_dependency "bundler", "~> 1.17"
  gem.add_development_dependency "rake", "~> 12.3"
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency "pg"
end
