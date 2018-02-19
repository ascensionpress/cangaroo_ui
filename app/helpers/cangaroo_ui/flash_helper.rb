module CangarooUI
  module FlashHelper

    def self.flash_key_to_bootstrap_class(key)
      case key
      when "notice" then "success"
      when "alert"  then "danger"
      end
    end

    def self.to_bootstrap_alert(renderer, flash)
      return nil unless flash.present?
      flash.keys.map do |key|
        renderer.content_tag(
          :div,
          flash[key],
          class: "alert alert-#{flash_key_to_bootstrap_class(key)}"
        )
      end.join("<br>").html_safe
    end

  end
end
