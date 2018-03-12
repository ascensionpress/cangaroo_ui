require 'rails_helper'

RSpec.describe CangarooUI::InteractivePollJob do

  subject do
    class_name = "InteractivePollFlow#{Time.now.to_i + rand(10_000)}"
    Object.class_eval <<-RUBY_EVAL
      class #{class_name} < Cangaroo::PollJob
        Rails.configuration.cangaroo.poll_jobs << self
        connection #{connection.name.to_sym.inspect}
        include CangarooUI::InteractiveJob
      end
    RUBY_EVAL
    Module.const_get(class_name).new
  end

  let(:connection) { FactoryBot.create(:ui_connection) }
  let(:job) { FactoryBot.create(:job) }

  before(:each) do
    allow(CangarooUI::Transaction).to receive(:valid_job_classes).and_return(
      CangarooUI::Transaction.valid_job_classes + [subject.class.name]
    )
  end

  describe 'create_transaction!' do
    before(:each) do
      # when the queue adapters are allowed to run in separate processes
      # they forward their job IDs to the #provider_job_id
      # since we aren't running a separate process in tests, this has to be faked
      allow(subject).to receive(:provider_job_id).and_return(job.id)
    end
    it 'is called during queueing' do
      expect(subject).to receive(:create_transaction!)
      subject.enqueue
    end
    it 'does not create a record' do
      expect{
        subject.enqueue
      }.to_not change{ CangarooUI::Record.count }
    end
    it 'creates a transaction' do
      expect{
        subject.enqueue
      }.to change{
        CangarooUI::Transaction.count
      }.by(1)
    end
    it 'saves destination and job in the transaction' do
      subject.create_transaction!
      tx = CangarooUI::Transaction.last
      expect(tx.record).to eq nil
      expect(tx.source_connection).to eq nil
      expect(tx.job_class).to eq subject.class.name
      expect(tx.active_job_id).to eq subject.job_id
      expect(tx.destination_connection).to eq subject.send(:destination_connection)
      expect(tx.job).to eq job
      expect(subject.associated_tx).to eq tx
    end
    it 'is not idempotent' do
      expect{
        5.times { subject.create_transaction! }
      }.to change{
        [ CangarooUI::Record.count, CangarooUI::Transaction.count ]
      }.from([0,0]).to([0,5])
    end
  end

  describe '_around_perform' do
    def create_associated_tx(job, flow)
      flow.provider_job_id = job.id
      tx = flow.create_transaction!
      expect(flow.associated_tx).to eq tx
    end
    def expect_it_to_resolve_duplicates(expectation, job)
      msg = expectation ? :to : :to_not
      expect_any_instance_of(
        CangarooUI::JobServiceFactory.infer_service_class
      ).send(msg, receive(:resolve_duplicate_failed_jobs!))
    end
    let(:blk) { Proc.new{} }
    it 'is called after performing' do
      expect(subject).to receive(:_around_perform)
      subject.perform_now
    end
    context 'the flow should not be performed' do
      before(:each) { allow(subject).to receive(:perform?).and_return(false) }
      it 'does not call the block' do
        expect(blk).to_not receive(:call)
        subject._around_perform(subject, blk)
      end
      it 'destroys the associated tx' do
        job = FactoryBot.create(:job)
        create_associated_tx(job, subject)
        expect_any_instance_of(CangarooUI::Transaction).to receive(:destroy)
        subject.perform_now
      end
    end
    context 'the flow should be performed' do
      before(:each) { allow(subject).to receive(:perform?).and_return(true) }
      it 'calls the block' do
        expect(blk).to receive(:call)
        subject._around_perform(subject, blk)
      end
      it 'does not destroy the associated tx' do
        job = FactoryBot.create(:job)
        create_associated_tx(job, subject)
        expect_any_instance_of(CangarooUI::Transaction).to_not receive(:destroy)
        subject.perform_now
      end
      it 'handles cases where there is no associated transaction' do
        expect(subject.associated_tx).to eq nil
        expect(subject).to_not receive(:resolve_duplicate_failed_jobs)
        expect{ subject._around_perform(subject, blk) }.to_not raise_exception
      end
      it 'does nothing if the job was unsuccessful' do
        failed_job = FactoryBot.create(:job, :failed)
        create_associated_tx(failed_job, subject)
        expect_it_to_resolve_duplicates(false, failed_job)
        subject._around_perform(subject, blk)
      end
      it 'does nothing if not configured to resolve duplicates' do
        job = FactoryBot.create(:job, :success)
        create_associated_tx(job, subject)
        expect(subject.on_success_resolve_duplicates?).to eq false
        expect_it_to_resolve_duplicates(false, job)
        subject._around_perform(subject, blk)
      end
      it 'resolves duplicates if configured to' do
        job = FactoryBot.create(:job, :success)
        create_associated_tx(job, subject)
        subject.class.on_success_resolve_duplicates(true)
        expect_it_to_resolve_duplicates(true, job)
        subject._around_perform(subject, blk)
      end
    end
  end

  describe 'on_success_resolve_duplicates' do
    it 'defaults to false' do
      expect(subject.class.on_success_resolve_duplicates).to eq false
      expect(subject.on_success_resolve_duplicates).to eq false
      expect(subject.on_success_resolve_duplicates?).to eq false
    end
    it 'can be set to failse' do
      subject.class.on_success_resolve_duplicates(false)
      expect(subject.class.on_success_resolve_duplicates).to eq false
      expect(subject.on_success_resolve_duplicates).to eq false
      expect(subject.on_success_resolve_duplicates?).to eq false
    end
    it 'can be set to true' do
      subject.class.on_success_resolve_duplicates(true)
      expect(subject.class.on_success_resolve_duplicates).to eq true
      expect(subject.on_success_resolve_duplicates).to eq true
      expect(subject.on_success_resolve_duplicates?).to eq true
    end
  end

end
