module CangarooUI
  class RetryJobsController < ApplicationController

    def update
      @tx = CangarooUI::Transaction.find(params[:id])

      respond_to do |format|
        if CangarooUI::TransactionRetrier.retry(@tx)
          flash.now[:notice] = "Job #{@tx.job_class} queued"
        else
          flash.now[:alert] = "Job #{@tx.job_class} could not be queued"
        end
        format.html { redirect_to transactions_path }
        format.js
      end
    end

  end
end
