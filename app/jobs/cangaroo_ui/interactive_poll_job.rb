module CangarooUI
  module InteractivePollJob

    def self.included(klass)
      klass.class_configuration :on_success_resolve_duplicates, false
      klass.around_enqueue {|flow, block| _around_enqueue(flow, block) }
      klass.after_perform  {|flow| _after_perform(flow)}
    end

    def _around_enqueue(flow, block)
      ActiveRecord::Base.transaction do
        delayed_job = block.call
        create_transaction!(flow, delayed_job)
      end
    rescue
      nil
    end

    def _after_perform(job)
      return unless tx = self.associated_tx
      delete_redundant_jobs(job, tx.job)
    end

    def associated_tx
      CangarooUI::Transaction.where(
        job_class: self.class.name,
        destination_connection: self.destination_connection
      ).last
    end

    def create_transaction!(flow, job)
      CangarooUI::Transaction.new(
        job:                    job,
        job_class:              flow.class.name,
        destination_connection: flow.destination_connection,
        source_connection:      nil, # polls aren't triggered by a source
        record:                 nil, # polls aren't associated with records
      ).save!
    end

    def on_success_resolve_duplicates?
      self.class.on_success_resolve_duplicates
    end

    def delete_redundant_jobs(flow, job)
      job_service = CangarooUI::JobServiceFactory.build(job: job, flow: flow)
      if job_service.success? && flow.on_success_resolve_duplicates?
        job_service.resolve_duplicate_failed_jobs!
      end
    end

  end
end
