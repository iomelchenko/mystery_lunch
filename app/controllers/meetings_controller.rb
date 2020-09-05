# frozen_string_literal: true

class MeetingsController < ApplicationController
  def index
    @allocations = MeetingsDatatable.new(view_context).call

    respond_to do |format|
      format.html
      format.json { render json: @allocations }
    end
  end
end
