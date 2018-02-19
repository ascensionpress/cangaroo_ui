module CangarooUI
  class ErrorsController < ApplicationController

    def index
      @transactions = CangarooUI::Transaction.failures
        .order(last_run: :desc)
        .paginate(page: params[:page])
    end

  end
end
