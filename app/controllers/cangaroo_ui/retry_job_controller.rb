module Cangaroo
  class RetryJobController < ApplicationController

    def update
      @tx = Cangaroo::Transaction.find(params[:id])

      respond_to do |format|
        if Cangaroo::TransactionRetrier.retry(@tx)
          flash.now[:notice] = "Job #{@tx.job_class} queued"
        else
          flash.now[:alert] = "Job #{@tx.job_class} could not be queued"
        end
        format.html { redirect_to routes.transactions_path }
        format.js
      end
    end

  end
end
