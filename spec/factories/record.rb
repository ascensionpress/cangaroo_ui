FactoryBot.define do

  factory :record, class: CangarooUI::Record do
    number { Array.new(10) { rand(0..9) }.join }
    kind "record"
    data { {fake: :payload} }

    trait :order do
      number { "R" + Array.new(10) { rand(0..9) }.join }
      kind "order"
      data do
        {
          "id"       => self.number,
          "status"   => "complete",
          "channel"  => "spree",
          "email"    => Faker::Internet.email,
          "currency" =>"USD",
        }
      end

    end
    trait :shipment do
      number { rand(190000..200000).to_s }
      kind "shipment"
      data do
        {
          "id"       => self.number,
          "order_id" => ("R" + Array.new(10) { rand(0..9) }.join),
          "status"   => "picked",
          "tracking" => "",
        }
      end
    end
  end

end
