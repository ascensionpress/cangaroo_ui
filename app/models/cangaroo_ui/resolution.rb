module CangarooUI
  class Resolution < CangarooUI::ApplicationRecord
    validates_presence_of :last_error

    belongs_to :tx, class_name: "CangarooUI::Transaction",
      foreign_key: :transaction_id,
      optional: false

  end
end
