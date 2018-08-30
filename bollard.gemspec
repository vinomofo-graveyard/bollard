$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bollard/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bollard"
  s.version     = Bollard::VERSION
  s.license     = "MIT"
  s.authors     = ["Michael Dilley"]
  s.email       = "mick@vinomofo.com"
  s.homepage    = "https://github.com/vinomofo/bollard"
  s.summary     = "Send a secure post somewhere"
  s.description = "Send a secure post somewhere"

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {spec,gemfiles}/*`.split("\n")

  s.add_dependency "jwt"

  s.add_development_dependency "activesupport", ">= 3.1"
  s.add_development_dependency "rspec", "~> 3.7"
  s.add_development_dependency "byebug"
  s.add_development_dependency "rake"
end
