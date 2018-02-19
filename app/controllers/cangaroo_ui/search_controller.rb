module CangarooUI
  class SearchController < ApplicationController

    rescue_from ActionController::ParameterMissing do
      redirect_to routes.transactions_path,
        alert: "Missing required search value"
    end

    def show
      @search = search_params
      @records = CangarooUI::Record.where("data LIKE ?", "%#{@search}%")
      @transactions = CangarooUI::Transaction.where(
        job: Delayed::Job.where("last_error LIKE ?", "%#{@search}%")
      ).or(
        CangarooUI::Transaction.where(record: @records)
      )
    end

    private

    def search_params
      params.require(:search).strip
    end

  end
end
