module CangarooUI
  class Transaction < CangarooUI::ApplicationRecord
    validates_presence_of :job_class

    # NOTE
    # We're using a custom validation here instead of #validates_inclusion_of
    # so that we can thoroughly test Transaction creation within Modules.
    # Rails does some kind of caching of its built-in validation methods. And,
    # since these modules are mixed into classes defined within specs, i.e. after
    # loading Rails, the caching causes false positives in the test suite.
    validate :valid_job_class

    def valid_job_class
      return if self.job_class.in?(self.class.valid_job_classes)
      errors.add(:job_class, "value #{self.job_class} is not configured with CangarooUI")
    end

    def self.valid_job_classes
      Rails.configuration.cangaroo.jobs.map(&:name) +
        Rails.configuration.cangaroo.poll_jobs.map(&:name)
    end

    has_one :resolution, class_name: "CangarooUI::Resolution",
      dependent: :destroy

    belongs_to :job, class_name: 'Delayed::Backend::ActiveRecord::Job',
      dependent: :destroy, optional: false

    # NOTE Making these optional so that we can dynamically assign the presence
    # validation based on job type: it will be optional for poll, not push, jobs.
    # The current version of rails only accepts a truthy/falsey value here
    # https://github.com/rails/rails/blob/185a30f75289ab158abd3c21536930c37af61338/activerecord/lib/active_record/associations/builder/belongs_to.rb#L144
    belongs_to :record, class_name: 'CangarooUI::Record', optional: true
    belongs_to :source_connection, class_name: 'CangarooUI::Connection',
      optional: true
    validates_presence_of [:record, :source_connection],
      if: :push_job?,
      message: "must exist"

    belongs_to :destination_connection, class_name: 'CangarooUI::Connection'

    alias :payload :record

    class State
      ALL = [
        FAILED    = 'failed',
        ACTIVE    = 'running',
        QUEUED    = 'queued',
        SCHEDULED = 'scheduled',
        FINISHED  = 'finished',
        RESOLVED  = 'resolved',
      ]
    end

    def state
      # TODO test this
      # TODO this needs to be made queueing-system-agnostic
      return State::RESOLVED if self.resolution.present?
      return State::FINISHED unless job = self.job
      return State::FAILED if job.failed_at.present? || job.last_error.present?
      return State::ACTIVE unless job.locked_at.nil?
      # TODO is this actually a possible state of the system?
      return State::SCHEDULED if job.run_at > job.created_at
      return State::QUEUED
    end

    def failed?() state == State::FAILED end

    # TODO expand to support other workers
    def self.job_class() Delayed::Job end

    scope :push_jobs, -> {
      where(job_class: Rails.configuration.cangaroo.jobs.map(&:name) )
    }
    scope :poll_jobs, -> {
      where(job_class: Rails.configuration.cangaroo.poll_jobs.map(&:name) )
    }
    scope :failures, -> {
      # TODO need to make this queuing-system-agnostic
      joins(:job).where.not(job_class.arel_table.name => {failed_at: nil})
    }
    scope :queued, -> {
      # TODO need to make this queuing-system-agnostic
      joins(:job).where(
        job_class.arel_table.name => {
          failed_at: nil,
          locked_at: nil
        }
      )
    }

    def push_job?
      Rails.configuration.cangaroo.jobs.map(&:name).include?(self.job_class)
    end

    def poll_job?
      Rails.configuration.cangaroo.poll_jobs.map(&:name).include?(self.job_class)
    end

  end
end
