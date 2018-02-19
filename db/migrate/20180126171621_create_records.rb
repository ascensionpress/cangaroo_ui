class CreateRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :cangaroo_records do |t|
      t.string :number
      t.string :kind
      t.text :data
      t.timestamps
    end
  end
end
