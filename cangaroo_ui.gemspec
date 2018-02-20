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
  s.test_files = Dir['spec/**/*']

  # TODO add cangaroo back as an official dependency once
  # cangaroo updates its code in ruby gems
  # s.add_dependency "cangaroo", ">= 1.2.0"
  s.add_dependency "twitter-bootstrap-rails", '>= 4.0.0'
  # TODO upgrade to 3.0.0 when this gets merged
  # https://github.com/seyhunak/twitter-bootstrap-rails/pull/930
  s.add_dependency "less-rails", '>= 2.8.0'

  s.add_development_dependency 'rspec-rails', '3.7.2'
  s.add_development_dependency 'factory_bot_rails', '4.8.2'
  s.add_development_dependency 'faker', '1.8.7'
  s.add_development_dependency 'delayed_job_active_record', '4.1.2'
  s.add_development_dependency 'pry'
  s.add_development_dependency "sqlite3"
end
