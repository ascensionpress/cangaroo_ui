module CangarooUI
  class TransactionsController < ApplicationController

    def index
      @push_txs = CangarooUI::Transaction.order(id: :desc)
        .where(job_class: Rails.configuration.cangaroo.jobs.map(&:name))
        .paginate(page: params[:page])
      @poll_txs = Rails.configuration.cangaroo.poll_jobs.map do |poll_job|
        CangarooUI::Transaction.where(job_class: poll_job.name).order(last_run: :desc).first
      end
    end

    def show
      @transaction = CangarooUI::Transaction.find(params[:id])
    end

  end
end
