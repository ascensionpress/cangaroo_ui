require 'cangaroo/connection'

FactoryBot.define do

  factory :ui_connection, class: Cangaroo::Connection do
    name { ("a".."z").to_a.shuffle.first(7).join.to_sym }
    url { "www.#{name}.com" }
    parameters nil
    key { SecureRandom.hex }
    token { SecureRandom.hex }
  end

end
