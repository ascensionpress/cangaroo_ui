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

  describe '_around_enqueue' do
    it 'is called during queueing' do
      expect(subject).to receive(:_around_enqueue)
      subject.enqueue
    end
    it 'calls the block passed in' do
      blk = double(:blk)
      expect(blk).to receive(:call)
      subject._around_enqueue(subject, blk)
    end
    it 'does not create a record' do
      expect{
        subject._around_enqueue(subject, -> { job })
      }.to_not change{ CangarooUI::Record.count }
    end
    it 'creates a transaction' do
      expect{
        subject._around_enqueue(subject, -> { job })
      }.to change{
        CangarooUI::Transaction.count
      }.by(1)
    end
    it 'saves destination and job in the transaction' do
      subject._around_enqueue(subject, -> { job })
      tx = CangarooUI::Transaction.last
      expect(tx.record).to eq nil
      expect(tx.source_connection).to eq nil
      expect(tx.job_class).to eq subject.class.name
      expect(tx.destination_connection).to eq subject.send(:destination_connection)
      expect(tx.job).to eq job
    end
    it 'is not idempotent' do
      expect{
        5.times { subject._around_enqueue(subject, -> { job }) }
      }.to change{
        [ CangarooUI::Record.count, CangarooUI::Transaction.count ]
      }.from([0,0]).to([0,5])
    end
    it 'rolls back changes if there is an error queueing job' do
      expect{
        subject._around_enqueue(subject, -> { raise 'YOU SHALL NOT PASS' })
      }.to_not change{ CangarooUI::Transaction.count }
    end
    it 'rolls back changes if there is an error creating the transaction' do
      allow_any_instance_of(CangarooUI::Transaction).to receive(:save!) { raise 'error' }
      expect{
        subject._around_enqueue(subject, -> {job})
      }.to_not change{ CangarooUI::Transaction.count }
    end
  end

  describe '_after_peform' do
    def create_associated_tx(job)
      FactoryBot.create(
        :transaction,
        job: job,
        job_class: subject.class.name,
        destination_connection_id: subject.send(:destination_connection).id
      )
    end
    def expect_it_to_resolve_duplicates(expectation, job)
      msg = expectation ? :to : :to_not
      expect_any_instance_of(
        CangarooUI::JobServiceFactory.get_class(job: job)
      ).send(msg, receive(:resolve_duplicate_failed_jobs!))
    end
    it 'is called after performing' do
      expect(subject).to receive(:_after_perform)
      subject.perform_now
    end
    it 'handles cases where there is no associated transaction' do
      expect(subject.associated_tx).to eq nil
      expect(subject).to_not receive(:delete_redundant_jobs)
      expect{ subject._after_perform(subject) }.to_not raise_exception
    end
    it 'does nothing if the job was unsuccessful' do
      failed_job = FactoryBot.create(:job, :failed)
      tx = create_associated_tx(failed_job)
      expect(subject.associated_tx).to eq tx
      expect_it_to_resolve_duplicates(false, failed_job)
      subject._after_perform(subject)
    end
    it 'does nothing if not configured to resolve duplicates' do
      job = FactoryBot.create(:job, :success)
      create_associated_tx(job)
      expect(subject.on_success_resolve_duplicates?).to eq false
      expect_it_to_resolve_duplicates(false, job)
      subject._after_perform(subject)
    end
    it 'resolves duplicates if configured to' do
      job = FactoryBot.create(:job, :success)
      create_associated_tx(job)
      subject.class.on_success_resolve_duplicates(true)
      expect_it_to_resolve_duplicates(true, job)
      subject._after_perform(subject)
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
