require 'cangaroo/poll_job'
require 'cangaroo/push_job'

class FakePollJob < Cangaroo::PollJob; end
class FakePushJob < Cangaroo::PushJob; end

RSpec.configure do |config|
  # reset config before each spec
  config.before(:each) do
    Rails.configuration.cangaroo.jobs      = [FakePushJob]
    Rails.configuration.cangaroo.poll_jobs = [FakePollJob]
    Rails.configuration.cangaroo.basic_auth = false
    Rails.configuration.cangaroo.logger = nil
  end
end
