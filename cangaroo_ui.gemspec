$:.push File.expand_path("../lib", __FILE__)
require "cangaroo_ui/version"

Gem::Specification.new do |s|
  s.name        = "cangaroo_ui"
  s.version     = CangarooUI::VERSION
  s.authors     = ["David Laprade"]
  s.email       = ["david.laprade@gmail.com"]
  s.homepage    = "https://github.com/ascensionpress/cangaroo_ui"
  s.summary     = "A drop-in user interface for cangaroo-based integrations"
  s.description = "A drop-in user interface for cangaroo-based integrations"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "cangaroo", ">= 1.2.0"
  s.add_dependency "twitter-bootstrap-rails", '>= 4.0.0'
  # upgrade to 3.0.0 when this gets merged
  # https://github.com/seyhunak/twitter-bootstrap-rails/pull/930
  s.add_dependency "less-rails", '>= 2.8.0'

  s.add_development_dependency "sqlite3"
end
