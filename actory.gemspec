# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name          = "actory"
  s.version       = "0.0.1"
  s.summary       = %q{Actor model like, concurrent and distributed framework for Ruby.}
  s.description   = %q{Actor model like, concurrent and distributed framework for Ruby.}
  s.authors       = ["Keisuke Takahashi"]
  s.email         = ["keithseahus@gmail.com"]
  s.files         = `git ls-files`.split($\)
  s.homepage      = "https://github.com/keithseahus/actory"

  s.license       = "Apache 2.0"
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  requires += ['msgpack-rpc', 'parallel', 'facter', 'progressbar']
  requires.each do |name|
    s.add_development_dependency name
    s.add_runtime_dependency name
  end
end
