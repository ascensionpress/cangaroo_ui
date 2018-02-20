FactoryBot.define do

  factory :resolution, class: CangarooUI::Resolution do
    tx factory: :transaction
    last_error "Something's not right here, guys!"
  end

end
