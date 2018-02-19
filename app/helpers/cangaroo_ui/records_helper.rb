module CangarooUI::RecordsHelper

  def self.record_kind_to_bootstrap_class(kind)
    # do this in Ruby to keep query generic
    @kinds ||= CangarooUI::Record.group(:kind).count.sort_by {|kind, count| -count}.to_h
    case kind
    when @kinds.keys[0] then "primary"
    when @kinds.keys[1] then "success"
    when @kinds.keys[2] then "info"
    when @kinds.keys[3] then "warning"
    else; "default"
    end
  end

  def self.record_kind_to_bootstrap_label(renderer, kind)
    bootstrap_class = record_kind_to_bootstrap_class(kind)
    renderer.content_tag(:span, kind, class: "label label-#{bootstrap_class}")
  end
end
