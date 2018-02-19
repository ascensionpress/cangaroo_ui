class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :cangaroo_transactions do |t|
      t.references :record, index: true
      t.references :source_connection, index: true
      t.references :destination_connection, index: true
      t.references :job

      t.string :job_class

      t.datetime :last_run

      t.timestamps
    end

    add_foreign_key :cangaroo_transactions, :cangaroo_records, column: :record_id
    add_foreign_key :cangaroo_transactions, :cangaroo_connections, column: :source_connection_id
    add_foreign_key :cangaroo_transactions, :cangaroo_connections, column: :destination_connection_id
  end
end
