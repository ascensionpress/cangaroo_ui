module CangarooUI
  module InteractiveJob

    def self.included(klass)
      klass.extend(SharedClassMethods)
      klass.include(SharedInstanceMethods)

      unless klass.push_job? || klass.poll_job?
        raise 'must be a subclass of Cangaroo::PushJob or Cangaroo::PollJob'
      end

      shared_setup(klass)

      klass.include(CangarooUI::InteractivePushJob) if klass.push_job?
      klass.include(CangarooUI::InteractivePollJob) if klass.poll_job?
    end

    def self.shared_setup(klass)
      klass.before_perform {|flow| _before_perform(flow)}
    end

    module SharedClassMethods
      def push_job?() ancestors.map(&:name).include?("Cangaroo::PushJob") end
      def poll_job?() ancestors.map(&:name).include?("Cangaroo::PollJob") end
    end

    module SharedInstanceMethods
      def push_job?() self.class.push_job? end

      def poll_job?() self.class.poll_job? end

      def associated_tx
        ::CangarooUI::Transaction.find_by_active_job_id(self.job_id)
      end

      def _before_perform(flow)
        return unless tx = flow.associated_tx
        tx.update(last_run: DateTime.now)
      end
    end

  end
end
