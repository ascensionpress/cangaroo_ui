module CangarooUI
  module JobService
    class DelayedJob < CangarooUI::JobService::Base

      def success?() job && job.failed_at.nil? && job.run_at < Time.now end

      def finished?() job.nil? end
      def failed?() job && (job.failed_at.present? || job.last_error.present?) end
      def active?() job && job.locked_at.present? end
      def queued?() job && job.locked_at.nil? && job.failed_at.nil? end
      # TODO is this actually a possible state of the system?
      def scheduled?() job && job.run_at > job.created_at end

      def self.failed_transactions
        ::CangarooUI::Transaction.joins(:job).where.not(
          Delayed::Job.arel_table.name => {failed_at: nil}
        )
      end

      def self.queued_transactions
        ::CangarooUI::Transaction.joins(:job).where(
          Delayed::Job.arel_table.name => {
            failed_at: nil,
            locked_at: nil
          }
        )
      end

      def resolve_duplicate_failed_jobs!
        CangarooUI::Transaction.failures.where(job_class: flow.class.name).find_in_batches do |batch|
          batch.each(&CangarooUI::TransactionResolver.method(:resolve))
        end
      end

    end
  end
end
