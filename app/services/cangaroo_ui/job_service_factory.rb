module Cangaroo
  class JobServiceFactory

    class UnsupportedJobClass < ArgumentError; end

    def self.supported_job_classes
      [
        (Delayed::Job.name if defined?(Delayed::Job))
      ]
    end

    def self.build(job:, flow:)
      unless job.class.name.in?(self.supported_job_classes)
        raise UnsupportedJobClass
      end
      case job.class.name
      when (Delayed::Job.name if defined?(Delayed::Job))
        Cangaroo::JobService::DelayedJob.new(job: job, flow: flow)
      end
    end

  end
end
