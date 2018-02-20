module CangarooUI
  class Record < CangarooUI::ApplicationRecord
    self.table_name = "cangaroo_records"

    validates_presence_of [:number, :kind, :data]

    has_many :transactions
    serialize :data, Hash
  end
end
