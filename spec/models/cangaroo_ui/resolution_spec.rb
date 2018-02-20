require 'rails_helper'

RSpec.describe CangarooUI::Resolution do
  let(:resolution) { FactoryBot.build_stubbed(:resolution) }

  it 'belongs to transactions' do
    expect(resolution.tx).to be_present
  end

  it 'is destroyed when associated transactions are destroyed' do
    allow_any_instance_of(CangarooUI::Transaction).to receive(:valid_job_class)
    resolution = FactoryBot.create(:resolution)
    expect {
      resolution.tx.destroy
    }.to change {
      described_class.count
    }.from(1).to(0)
  end

  it 'requires an error message' do
    expect(resolution).to be_valid
    resolution.last_error = nil
    expect(resolution).to_not be_valid
  end

end
