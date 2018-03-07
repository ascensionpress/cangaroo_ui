module CangarooUI
  class JobServiceFactory

    class UnsupportedJobClass < ArgumentError; end

    class << self

      def build(job:, flow:)
        klass = infer_service_class
        klass.new(job: job, flow: flow)
      end

      def infer_service_class
        if defined?(Delayed::Job)
          CangarooUI::JobService::DelayedJob
        else
          raise UnsupportedJobClass.new("currently only DelayedJob is supported")
        end
      end

    end
  end
end
