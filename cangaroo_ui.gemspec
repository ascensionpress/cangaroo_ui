$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cangaroo_ui/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cangaroo_ui"
  s.version     = CangarooUi::VERSION
  s.authors     = ["David Laprade"]
  s.email       = ["david.laprade@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of CangarooUi."
  s.description = "TODO: Description of CangarooUi."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_development_dependency "sqlite3"
end
