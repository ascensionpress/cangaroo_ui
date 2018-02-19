class CreateCangarooResolutions < ActiveRecord::Migration[5.1]
  def change
    create_table :cangaroo_resolutions do |t|
      t.references :transaction, index: true
      t.text :last_error
      t.timestamps
    end
    add_foreign_key :cangaroo_resolutions, :cangaroo_transactions, column: :transaction_id
  end
end
