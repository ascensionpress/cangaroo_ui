# This migration comes from cangaroo (originally 20160317020230)
class CreateCangarooPollTimestamps < ActiveRecord::Migration[5.1]
  def change
    create_table :cangaroo_poll_timestamps do |t|
      t.string     :job
      t.references :connection
      t.text       :value
      t.timestamps
    end

    add_index :cangaroo_poll_timestamps, [:job], :name => 'index_cangaroo_poll_timestamps_on_job'
  end
end
