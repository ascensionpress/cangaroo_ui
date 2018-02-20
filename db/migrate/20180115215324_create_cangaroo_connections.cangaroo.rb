# This migration comes from cangaroo (originally 20151028172151)
class CreateCangarooConnections < ActiveRecord::Migration[5.1]
  def change
    create_table :cangaroo_connections do |t|
      t.string :name
      t.string :url
      t.string :key
      t.string :token

      t.timestamps null: false
    end
  end
end
