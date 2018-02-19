module Cangaroo
  class ResolveJobController < ApplicationController

    def update
      @tx = Cangaroo::Transaction.find(params[:id])

      respond_to do |format|
        if Cangaroo::TransactionResolver.resolve(@tx)
          flash.now[:notice] = "Job #{@tx.job_class} resolved"
        else
          flash.now[:alert] = "Job #{@tx.job_class} could not be resolved"
        end
        format.html { redirect_to routes.transactions_path }
        format.js
      end
    end

  end
end
