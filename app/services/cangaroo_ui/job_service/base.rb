module CangarooUI
  module JobService
    class Base

    # NOTE
    # This service is meant to abstract implementation details of the different
    # job queue-ing systems and provide a shared interface for them

    attr_reader :job
    attr_reader :flow

    def initialize(job:, flow: nil)
      @job = job
      @flow = flow
    end

    class NotImplemented < StandardError; end

    def success?() raise NotImplemented end
    def resolve_duplicate_failed_jobs!() raise NotImplemented end

    end
  end
end
