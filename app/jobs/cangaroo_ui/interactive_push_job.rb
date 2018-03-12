module CangarooUI
  module InteractivePushJob

    def self.included(klass)
      klass.around_enqueue {|flow, block| _around_enqueue(flow, block) }
    end

    def _around_enqueue(flow, block)
      ActiveRecord::Base.transaction do
        # NOTE We can't use #associated_tx here because it is flow-specific.
        # Different instances of the same flow class will have different
        # job_ids, and so will have different #associated_tx values.
        # The idea is that if a new instance of the same flow class is triggered
        # we want to pull up the old instance's transaction
        record = search_for_existing_record(flow)
        tx     = search_for_existing_transaction(flow, record)
        record = create_or_update_record!(flow, record, tx)

        delayed_job = block.call

        create_transaction!(tx, record, flow, delayed_job)
      end
    rescue
      nil
    end

    def search_for_existing_record(flow)
      CangarooUI::Record.find_by_number_and_kind(
        flow.payload["id"],
        flow.type.singularize,
      )
    end

    def search_for_existing_transaction(flow, record)
      return unless record
      record.transactions.where(
        job_class: flow.class.name,
        source_connection: flow.source_connection,
        destination_connection: flow.destination_connection,
      ).last
    end

    def create_or_update_record!(flow, record, tx)
      return unless flow.payload && flow.payload["id"]

      unless record
        return CangarooUI::Record.create!(
          number: flow.payload["id"],
          kind: flow.type.singularize,
          data: flow.payload,
        )
      end

      # this exact job has already run, so the payload was already merged, skip
      return record if record && tx

      # the job is running for the first time, so we need to merge the payload
      record.update!(data: record.data.merge(flow.payload))
      record
    end

    def transform
      record = self.find_associated_record!(self.payload)
      { type.singularize => record.data }
    end

    def find_associated_record!(payload)
      CangarooUI::Record.find_by_number_and_kind!(
        payload["id"],
        self.type.singularize,
      )
    end

    class MissingState < StandardError; end
    def create_transaction!(existing_tx, record, flow, job)
      return if existing_tx
      raise MissingState unless record && flow && job

      CangarooUI::Transaction.create!(
        job:                    job,
        record:                 record,
        job_class:              flow.class.name,
        active_job_id:          flow.job_id,
        source_connection:      flow.source_connection,
        destination_connection: flow.destination_connection,
      )
    end

    def is_original_attempt?
      record = search_for_existing_record(self)
      return true unless record
      !CangarooUI::Transaction.exists?(
        record: record,
        job_class: self.class.name,
        source_connection: self.source_connection,
        destination_connection: self.destination_connection
      )
    end

  end
end
