# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "actory"
  gem.authors       = ["Keisuke Takahashi"]
  gem.email         = ["keithseahus@gmail.com"]
  gem.description   = %q{Actor model like, concurrent and distributed framework for Ruby.}
  gem.summary       = %q{Actor model like, concurrent and distributed framework for Ruby.}
  gem.homepage      = "https://github.com/keithseahus/actory"
  gem.version       = "0.0.1"
  gem.license       = "Apache 2.0"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  requires += ['rake']
  requires.each {|name| gem.add_development_dependency name}
end
