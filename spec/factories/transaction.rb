FactoryBot.define do

  factory :transaction, class: CangarooUI::Transaction do
    destination_connection factory: :ui_connection
    source_connection      factory: :ui_connection
    record
    job
    active_job_id "9ac8d967-df9c-44fe-b91f-3fc3d6adbff3"
    job_class "MyFake::Job"
  end

end
