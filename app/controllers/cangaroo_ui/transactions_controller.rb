module Cangaroo
  class TransactionsController < ApplicationController

    def index
      @push_txs = Cangaroo::Transaction.order(id: :desc)
        .where(job_class: Rails.configuration.cangaroo.jobs.map(&:name))
        .paginate(page: params[:page])
      @poll_txs = Rails.configuration.cangaroo.poll_jobs.map do |poll_job|
        Cangaroo::Transaction.where(job_class: poll_job.name).order(last_run: :desc).first
      end
    end

    def show
      @transaction = Cangaroo::Transaction.find(params[:id])
    end

  end
end
