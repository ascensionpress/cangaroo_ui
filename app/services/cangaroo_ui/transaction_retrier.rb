module CangarooUI
  class TransactionRetrier
    def self.retry(tx)
      # NOTE this is definitely specific to Delayed::Job
      return false unless tx.job
      return false unless tx.job.failed_at
      tx.job.update_attributes(
        locked_at: nil,
        last_error: "",
        failed_at: nil
      )
    end
  end
end
