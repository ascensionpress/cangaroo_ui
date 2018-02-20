FactoryBot.define do

  factory :transaction, class: CangarooUI::Transaction do
    destination_connection factory: :ui_connection
    source_connection      factory: :ui_connection
    record
    job

    job_class "MyFake::Job"
  end

end
