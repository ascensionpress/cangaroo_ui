require 'delayed_job_active_record'

FactoryBot.define do

  factory :job, class: Delayed::Job do
    priority 0
    attempts 0
    locked_at nil
    locked_by nil
    queue nil
    created_at DateTime.now - 1.month
    handler "{ruby: 'handler'}"

    trait :success do
      run_at Time.now
      failed_at nil
    end

    trait :untried do
      failed_at nil
      run_at nil
    end

    trait :failed do
      last_error "StandardError"
      failed_at DateTime.now - 2.weeks
      run_at DateTime.now - 1.month
      attempts 1
    end
  end

end
