# frozen_string_literal: true

class MeetingsController < ApplicationController
  def index
    collection =
      if request.xhr?
        MeetingsSearcher.new(params, Allocation.all).call
      else
        Allocation.with_current_meetings
      end

    @data = MeetingsDatatable.new(view_context, collection).call

    respond_to do |format|
      format.html
      format.json { render json: @data }
    end
  end
end
