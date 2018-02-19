module CangarooUI
  module ApplicationHelper
    def self.to_humanized_dt(datetime)
      return nil unless datetime
      zone = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")
      datetime.in_time_zone(zone).strftime("%-m/%-d/%y %-l:%M%P")
    end
  end
end
