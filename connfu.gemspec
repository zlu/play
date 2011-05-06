# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "connfu/version"

Gem::Specification.new do |s|
  s.name        = "connfu"
  s.version     = Connfu::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Zhao Lu"]
  s.email       = %q{zlu@me.com}
  s.date        = %q{2011-05-06}
  s.homepage    = "http://github.com/zlu/play"
  s.summary     = %q{Ruby DSL for creating telephony applications}
  s.description = %q{Ruby DSL for creating telephony applications}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ["lib"]

  s.rdoc_options = %w{--charset=UTF-8}
  s.extra_rdoc_files = %w{README.md}

  s.add_dependency("blather", ["0.4.16"])
  s.add_dependency("awesome_print", ["0.3.2"])
  s.add_dependency("extensions", ["0.6.0"])

  s.add_development_dependency("bundler", ["1.0.13"])
  s.add_development_dependency("rake", ["0.8.7"])
  s.add_development_dependency("rspec", ["2.5.0"])
end
