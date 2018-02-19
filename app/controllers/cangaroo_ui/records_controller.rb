module CangarooUI
  class RecordsController < ApplicationController

    class UneditableWithoutFailuresError < StandardError; end

    def index
      @records = CangarooUI::Record.order(id: :desc)
      @queried_kind = kind_filter_from_params
      @records = @records.where(kind: @queried_kind) if @queried_kind
      @records = @records.paginate(page: params[:page])
    end

    def show
      @record = CangarooUI::Record.find(params[:id])
      @transactions = @record.transactions
    end

    def update
      @record = CangarooUI::Record.find(params[:id])
      respond_to do |format|
        if update_record(@record, cangaroo_record_params)
          flash.now[:notice] = "Record was successfully updated."
          format.html { redirect_to @record }
          format.js
        else
          flash.now[:alert] = @record.errors.full_messages.to_sentence
          format.html { render :show }
          format.js
        end
      end
    end

    private
      def kind_filter_from_params
        return unless kind = params.permit(:kind)[:kind].presence
        return unless CangarooUI::Record.exists?(kind: kind)
        kind
      end

      def cangaroo_record_params
        params.require(:record).permit(:data)
      end
      def update_record(record, hash)
        return record unless record && hash[:data].presence
        raise UneditableWithoutFailuresError unless record.transactions.any?(&:failed?)
        record.update(data: JSON.parse(hash[:data]))
      rescue JSON::ParserError
        record.errors.add(:data, "is not valid JSON")
        false
      rescue UneditableWithoutFailuresError
        # only allow users to edit payloads associated with failures
        record.errors.add(:data, "is not editable")
        false
      end
  end
end
