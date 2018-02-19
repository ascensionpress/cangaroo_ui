module CangarooUI
  module TransactionsHelper

    def self.state_to_bootstrap_label(renderer, transaction)
      case state = transaction.state
      when CangarooUI::Transaction::State::FINISHED
        renderer.content_tag(:span, "ok", class: "label label-success")
      when CangarooUI::Transaction::State::FAILED
        renderer.content_tag(:span, state, class: "label label-danger") +
        renderer.content_tag(
        :em,
        "<br>".html_safe + clean_job_error(transaction.job.last_error)
        )
      when CangarooUI::Transaction::State::ACTIVE
        renderer.content_tag(:span, state, class: "label label-warning")
      when CangarooUI::Transaction::State::SCHEDULED
        renderer.content_tag(:span, state, class: "label label-default")
      when CangarooUI::Transaction::State::QUEUED
        renderer.content_tag(:span, state, class: "label label-default")
      when CangarooUI::Transaction::State::RESOLVED
        resolution = transaction.resolution
        renderer.content_tag(:span, state, class: "label label-info") +
        renderer.content_tag(
          :span,
          " at #{CangarooUI::ApplicationHelper.to_humanized_dt(resolution.created_at)}"
        ) + "<br>".html_safe +
        renderer.content_tag(:em, clean_job_error(resolution.last_error))
      end
    end

    def self.clean_job_error(job_error)
      # remove stacktraces from job errors
      job_error.match(/^.*(\n)/).to_s.gsub("\n", "").presence ||
        (job_error.to_s.first(200) + "...")
    end

  end
end
