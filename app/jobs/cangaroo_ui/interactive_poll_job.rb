module CangarooUI
  module InteractivePollJob

    def self.included(klass)
      klass.class_configuration :on_success_resolve_duplicates, false
      klass.after_enqueue :create_transaction!
      klass.around_perform {|flow, block| _around_perform(flow, block) }
    end

    def _around_perform(flow, block)
      tx = self.associated_tx
      if flow.perform?(DateTime.now)
        block.call
        resolve_duplicate_failed_jobs(flow, tx.job) if tx
      else
        tx.destroy if tx
      end
    end

    def create_transaction!
      tx = CangarooUI::Transaction.new(
        job_id:                 self.provider_job_id,
        job_class:              self.class.name,
        active_job_id:          self.job_id,
        destination_connection: self.destination_connection,
        source_connection:      nil, # polls aren't triggered by a source
        record:                 nil, # polls aren't associated with records
      )
      tx.save!
      tx
    end

    def on_success_resolve_duplicates?
      self.class.on_success_resolve_duplicates
    end

    def resolve_duplicate_failed_jobs(flow, job)
      job_service = CangarooUI::JobServiceFactory.build(job: job, flow: flow)
      if job_service.success? && flow.on_success_resolve_duplicates?
        job_service.resolve_duplicate_failed_jobs!
      end
    end

  end
end
