module Cangaroo
  class JobsController < ApplicationController

    def index
      @jobs = Delayed::Job.where(failed_at: nil)
        .paginate(page: params[:page])
    end

  end
end
