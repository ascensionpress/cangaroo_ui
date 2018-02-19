module Cangaroo
  class ErrorsController < ApplicationController

    def index
      @transactions = Cangaroo::Transaction.failures
        .order(last_run: :desc)
        .paginate(page: params[:page])
    end

  end
end
