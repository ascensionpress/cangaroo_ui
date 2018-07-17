module CangarooUI
  class TransactionsController < ApplicationController

    def index
      # if this logic gets any more complex, abstract into a search service
      @push_txs = CangarooUI::Transaction.order(id: :desc)
        .where(job_class: Rails.configuration.cangaroo.jobs.map(&:name))
      if @job_class = params[:job_class].presence
        @push_txs = @push_txs.where(job_class: @job_class)
      else
        @poll_txs = Rails.configuration.cangaroo.poll_jobs.map do |poll_job|
          CangarooUI::Transaction.where(job_class: poll_job.name).order(last_run: :desc).first
        end
      end
      @push_txs = @push_txs.paginate(page: params[:page])
    end

    def show
      @transaction = CangarooUI::Transaction.find(params[:id])
    end

  end
end
