module Cangaroo
  module JobService
    class DelayedJob < Cangaroo::JobService::Base

      def success?
        job.failed_at.nil? && job.run_at < Time.now
      end

      def resolve_duplicate_failed_jobs!
        Cangaroo::Transaction.failures.where(job_class: flow.class.name).find_in_batches do |batch|
          batch.each(&Cangaroo::TransactionResolver.method(:resolve))
        end
      end

    end
  end
end
