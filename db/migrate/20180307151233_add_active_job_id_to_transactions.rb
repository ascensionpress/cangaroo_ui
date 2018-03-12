class AddActiveJobIdToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :cangaroo_transactions, :active_job_id, :string, index: true
  end
end
