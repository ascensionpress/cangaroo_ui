module CangarooUI
  class TransactionResolver

    def self.resolve(tx)
      return false unless tx.job
      return false unless tx.job.failed_at

      ActiveRecord::Base.transaction do
        tx.create_resolution!(last_error: tx.job.last_error)
        tx.job.destroy
      end

      true
    rescue
      false
    end

  end
end
