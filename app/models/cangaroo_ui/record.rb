module CangarooUI
  class Record < CangarooUI::ApplicationRecord
    validates_presence_of [:number, :kind, :data]

    has_many :transactions
    serialize :data, Hash
  end
end
