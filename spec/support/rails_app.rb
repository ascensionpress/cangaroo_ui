require 'active_record/railtie'
require 'action_controller/railtie'
require 'active_job/railtie'
require 'action_dispatch/railtie'
require 'securerandom'

require 'cangaroo'
require 'cangaroo_ui'

database_path = File.expand_path('../../../tmp/cangaroo_test.sqlite3', __FILE__)
ENV['DATABASE_URL'] = "sqlite3://#{database_path}"

# Initialize our test app

class RailsApp < Rails::Application
  config.active_job.queue_adapter = :inline
  config.secret_key_base = SecureRandom.hex
  config.eager_load = false
end

RailsApp.initialize!

ActiveRecord::Migrator.migrate "db/migrate"

RailsApp.routes.draw do
  mount CangarooUI::Engine => "/cangaroo_ui"
end
