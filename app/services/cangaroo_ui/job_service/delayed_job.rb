module CangarooUI
  module JobService
    class DelayedJob < CangarooUI::JobService::Base

      def success?
        job.failed_at.nil? && job.run_at < Time.now
      end

      def resolve_duplicate_failed_jobs!
        CangarooUI::Transaction.failures.where(job_class: flow.class.name).find_in_batches do |batch|
          batch.each(&CangarooUI::TransactionResolver.method(:resolve))
        end
      end

    end
  end
end
