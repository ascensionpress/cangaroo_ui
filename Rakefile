begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CangarooUI'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'active_record'
include ActiveRecord::Tasks

class Seeder
  def load_seed() end
end

root = File.expand_path '..', __FILE__

DatabaseTasks.env = ENV['ENV'] || 'development'
default_db_conf = {"adapter"=>"sqlite3", "pool"=>5, "timeout"=>5000}
DatabaseTasks.database_configuration = {
  "default"     => default_db_conf,
  "development" => default_db_conf.merge({"database"=>"db/development.sqlite3"}),
  "test"        => default_db_conf.merge({"database"=>"db/test.sqlite3"}),
  "production"  => default_db_conf.merge({"database"=>"db/production.sqlite3"})
}
DatabaseTasks.db_dir = File.join root, 'db'
DatabaseTasks.fixtures_path = File.join root, 'test/fixtures'
DatabaseTasks.migrations_paths = [File.join(root, 'db/migrate')]
DatabaseTasks.seed_loader = Seeder.new
DatabaseTasks.root = root

task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection DatabaseTasks.env.to_sym
end

load 'active_record/railties/databases.rake'

load 'rails/tasks/statistics.rake'

require 'bundler/gem_tasks'
