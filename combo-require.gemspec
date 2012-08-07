# -*- encoding: utf-8 -*-
require File.expand_path('../lib/combo-require/rails/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "combo-require"
  s.version     = ComboRequire::Rails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lenny Burdette"]
  s.email       = ["lburdette@zappos.com"]
  s.homepage    = "http://expo.apps.zappos.com"
  s.summary     = "A minimal version of the requirejs/AMD API the Rails asset pipeline."
  s.description = ""

  s.required_rubygems_version = ">= 1.3.6"
  # s.rubyforge_project         = "responsive-header"

  s.add_dependency "railties",      ">= 3.2.0", "< 5.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.require_paths = ["lib"]

  s.add_development_dependency "geminabox"
end