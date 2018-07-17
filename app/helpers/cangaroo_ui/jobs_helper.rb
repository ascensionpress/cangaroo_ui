module CangarooUI
  module JobsHelper

    def self.job_status_badge(renderer, job)
      if job.locked_at
        return renderer.content_tag(:span, 'running', class: 'label label-warning')
      end
      if job.run_at > job.created_at
        return renderer.content_tag(:span, 'scheduled', class: 'label label-default')
      end
      return renderer.content_tag(:span, 'queued', class: 'label label-default')
    end

    def self.handler_to_job_class(job)
      job_names = Rails.configuration.cangaroo.jobs.map(&:name) +
        Rails.configuration.cangaroo.poll_jobs.map(&:name)
      job.handler.match(Regexp.union job_names).to_s
    end

    def self.job_to_record_link(renderer, job)
      return unless tx = CangarooUI::Transaction.find_by_job_id(job.id)
      return "N/A" if tx.poll_job?
      return unless record = tx.record
      renderer.link_to(
        "#{record.kind} ##{record.number}",
        renderer.record_path(record)
      )
    end

  end
end
