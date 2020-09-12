# frozen_string_literal: true

class MeetingsCreator
  attr_reader :month, :year

  def initialize(month: Date.current.month, year: Date.current.year)
    @month = month
    @year = year
  end

  def call(user_id, matched_user_id)
    meeting_params = buid_meeting_params(user_id, matched_user_id)
    create_meeting(meeting_params)
  end

  private

  def create_meeting(meeting_params)
    meeting = Meeting.create!(
      year: year,
      month: month
    )

    [meeting_params[:user_id], meeting_params[:matched_user_id]].each do |user_id|
      Allocation.create!(
        meeting_id: meeting.id,
        user_id: user_id
      )
    end
  end

  def buid_meeting_params(user_id, matched_user_id)
    {
      user_id: user_id,
      matched_user_id: matched_user_id
    }
  end
end
