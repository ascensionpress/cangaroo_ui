# This migration comes from cangaroo (originally 20151030140821)
class AddParametersToCangarooConnection < ActiveRecord::Migration[5.1]
  def change
    add_column :cangaroo_connections, :parameters, :text
  end
end
