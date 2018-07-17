require 'rails_helper'

RSpec.describe CangarooUI::InteractivePushJob do
  def build_flow_class(connection:)
    class_name = "InteractivePushFlow#{Time.now.to_i + rand(10_000)}"
    Object.class_eval <<-RUBY_EVAL
      class #{class_name} < Cangaroo::PushJob
        Rails.configuration.cangaroo.jobs << self
        connection #{connection.name.to_sym.inspect}
        include CangarooUI::InteractiveJob
      end
    RUBY_EVAL
    Module.const_get(class_name)
  end

  subject do
    build_flow_class(connection: destination).new(
      source_connection: source,
      type: "orders",
      payload: payload
    )
  end

  let(:destination) { FactoryBot.create(:ui_connection) }
  let(:source)      { FactoryBot.create(:ui_connection) }
  let(:payload) { FactoryBot.build(:record, :order).data }
  let(:job) { FactoryBot.create(:job) }

  before(:each) do
    allow_any_instance_of(CangarooUI::Transaction).to receive(:valid_job_class)
      .and_return(true)
  end

  describe '_around_enqueue' do
    it 'is called during queueing' do
      expect(subject).to receive(:_around_enqueue)
      subject.enqueue
    end
    it 'calls the block passed in' do
      blk = double(:blk)
      expect(blk).to receive(:call)
      allow(subject).to receive(:create_transaction!)

      subject._around_enqueue(subject, blk)
    end
    it 'creates a record' do
      expect{
        subject._around_enqueue(subject, -> { job })
      }.to change{
        CangarooUI::Record.count
      }.by(1)
    end
    it 'saves the payload in the record data' do
      subject._around_enqueue(subject, -> { job })
      record = CangarooUI::Record.last
      expect(record.number).to eq payload["id"]
      expect(record.kind).to eq "order"
      expect(record.data).to eq payload
    end
    it 'creates a transaction' do
      expect{
        subject._around_enqueue(subject, -> { job })
      }.to change{
        CangarooUI::Transaction.count
      }.by(1)
    end
    it 'saves source, destination, job, and record in the transaction' do
      subject._around_enqueue(subject, -> { job })
      record = CangarooUI::Record.last
      tx = CangarooUI::Transaction.last
      expect(tx.record).to eq record
      expect(tx.job_class).to eq subject.class.name
      expect(tx.source_connection).to eq subject.source_connection
      expect(tx.destination_connection).to eq destination
      expect(tx.job).to eq job
    end
    it 'is idempotent' do
      expect{
        5.times { subject._around_enqueue(subject, -> { job }) }
      }.to change{
        [ CangarooUI::Record.count, CangarooUI::Transaction.count ]
      }.from([0,0]).to([1,1])
    end
    it 'allows queueing errors to bubble up' do # so they can be reported by error apps
      expect {
        subject._around_enqueue(subject, -> { raise 'YOU SHALL NOT PASS' })
      }.to raise_error("YOU SHALL NOT PASS")
    end
    it 'rolls back changes if there is an error queueing job' do
      # doesn't rollback changes when there isn't an error
      expect{
        subject._around_enqueue(subject, -> {job})
      }.to change{ [ CangarooUI::Record.count, CangarooUI::Transaction.count ] }

      # but when there is...
      expect{
        begin
          subject._around_enqueue(subject, -> { raise 'YOU SHALL NOT PASS' })
        rescue => e
          raise e unless e.message == "YOU SHALL NOT PASS"
        end
      }.to_not change{ [ CangarooUI::Record.count, CangarooUI::Transaction.count ] }
    end
    it 'rolls back changes if there is an error creating the record' do
      allow_any_instance_of(CangarooUI::Record).to receive(:save!) { raise 'error' }
      expect{
        begin
          subject._around_enqueue(subject, -> {job})
        rescue => e
          raise e unless e.message == "error"
        end
      }.to_not change{ [ CangarooUI::Record.count, CangarooUI::Transaction.count ] }
    end
    it 'rolls back changes if there is an error creating the transaction' do
      allow_any_instance_of(CangarooUI::Transaction).to receive(:save!) { raise 'error' }
      expect{
        begin
          subject._around_enqueue(subject, -> {job})
        rescue => e
          raise e unless e.message == "error"
        end
      }.to_not change{ [ CangarooUI::Record.count, CangarooUI::Transaction.count ] }
    end
    context 'payload merging' do
      # CASES
      #   persist - job triggered by incoming payload, e.g. from Spree
      #   persist - job triggered by polling payload, e.g. from NetSuite poll
      #   don't   - job triggered by retry through GUI
      #   don't   - job triggered by automatic worker retry
      subject do
        build_flow_class(connection: destination).new(
          source_connection: source,
          type: "shipments",
          payload: payload
        )
      end

      context 'when there is no existing record' do
        let(:payload) do
          FactoryBot.build_stubbed(:record, :shipment).data.merge(
            "status" => "shipped",
            "tracking" => "1k2j123k120123",
          )
        end
        it 'creates a record and then does not subsequently merge ontop of it' do
          expect{
            subject._around_enqueue(subject, -> { job })
          }.to change { CangarooUI::Record.count }.from(0).to(1)
          record = CangarooUI::Record.last
          expect(record.data).to eq(payload)
          record.update(data: record.data.merge("status" => "edited status"))
          expect(record.reload.data["status"]).to eq("edited status")

          expect{
            subject._around_enqueue(subject, -> { job })
          }.to_not change{ record.data }
        end
      end

      context 'when there is an existing record' do
        let!(:record)  { FactoryBot.create(:record, :shipment) }
        let(:payload) do
          record.data.merge(
            "status" => "shipped",
            "tracking" => "1k2j123k120123",
          )
        end

        it 'happens on top of the existing payload' do
          expect{
            subject._around_enqueue(subject, -> { job })
          }.to change{
            record.reload
            [record.data["status"], record.data["tracking"]]
          }.from(["picked", ""]).to(["shipped","1k2j123k120123"])
        end

        it 'happens on top of existing payload edits' do
          record.update(data: record.data.merge("status" => "edited status"))
          expect{
            subject._around_enqueue(subject, -> { job })
          }.to change{
            record.reload.data["status"]
          }.from("edited status").to("shipped")
        end

        it 'does not overwrite payload edits occuring after the intial merge' do
          expect(record.data["status"]).to eq("picked")
          subject._around_enqueue(subject, -> { job })
          expect(record.reload.data["status"]).to eq("shipped")
          record.update(data: record.data.merge("status" => "edited status"))
          expect(record.reload.data["status"]).to eq("edited status")

          expect{
            subject._around_enqueue(subject, -> { job })
          }.to_not change{ record.reload.data }
        end

        it 'results in a transformation including the merged payload' do
          expect(record.data["status"]).to eq("picked")
          subject._around_enqueue(subject, -> { job })
          expect(subject.transform["shipment"]["status"]).to eq("shipped")
        end

        it 'results in a transformation that includes the edited payload' do
          # simulate initial import into system
          subject._around_enqueue(subject, -> { job })
          # simulate editing a record
          record.update(data: record.reload.data.merge("status" => "edited status"))
          # now confirm the data that would be sent when retrying
          new_payload = subject.transform["shipment"]
          expect(new_payload["status"]).to eq("edited status")
          expect(new_payload["tracking"]).to eq(payload["tracking"])
        end

        context 'and when there is an existing transaction' do
          let!(:transaction) do
            FactoryBot.create(
              :transaction,
              job_class: subject.class.name,
              record: record,
              source_connection: subject.source_connection,
              destination_connection: destination,
            )
          end
          it 'does not merge on top of the existing payload' do
            expect{
              subject._around_enqueue(subject, -> { job })
            }.to_not change{ record.reload.data }
          end
          it 'does not overwrite edits to the existing payload' do
            record.update(data: record.data.merge("status" => "edited status"))
            expect(record.reload.data["status"]).to eq("edited status")
            expect{
              subject._around_enqueue(subject, -> { job })
            }.to_not change{ record.reload.data }
          end
        end
      end

    end
  end
end
