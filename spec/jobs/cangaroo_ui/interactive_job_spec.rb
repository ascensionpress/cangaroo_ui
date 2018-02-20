require 'rails_helper'

RSpec.describe CangarooUI::InteractiveJob do
  it 'does not raise if included in a Cangaroo subclass' do
    expect{
      class TestPushJob9876 < Cangaroo::PushJob; include CangarooUI::InteractiveJob; end
      class TestPollJob9876 < Cangaroo::PollJob; include CangarooUI::InteractiveJob; end
    }.to_not raise_error
  end
  it 'raises if included in a non-job class' do
    expect{
      class NonActiveJob; include CangarooUI::InteractiveJob; end
    }.to raise_error('must be a subclass of Cangaroo::PushJob or Cangaroo::PollJob')
  end
end
