module CangarooUI
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    def self.table_name_prefix
      'cangaroo_'
    end

  end
end
