module CangarooUI
  class JobServiceFactory

    class UnsupportedJobClass < ArgumentError; end

    class << self

      def supported_job_classes
        [
          (Delayed::Job.name if defined?(Delayed::Job))
        ].compact
      end

      def build(job:, flow:)
        klass = get_class(job: job)
        klass.new(job: job, flow: flow)
      end

      def get_class(job:)
        unless job.class.name.in?(self.supported_job_classes)
          raise UnsupportedJobClass
        end
        case job.class.name
        when (defined?(Delayed::Job) ? Delayed::Job.name : 'Delayed::Job')
          CangarooUI::JobService::DelayedJob
        end
      end

    end
  end
end
