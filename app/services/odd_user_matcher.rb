# frozen_string_literal: true

class OddUserMatcher
  attr_reader :month, :year

  def initialize(month: Date.current.month, year: Date.current.year)
    @month = month
    @year = year
  end

  def call(odd_user_id, allowed_ids, not_allowed_ids)
    meeting_id = find_meeting_id(odd_user_id, allowed_ids, not_allowed_ids)

    return unless meeting_id

    join_existing_meeting(odd_user_id, meeting_id)
  end

  private

  def find_meeting_id(odd_user_id, allowed_ids, not_allowed_ids)
    (allowed_ids - not_allowed_ids).each do |candidate_id|
      meeting =
        Meeting
          .joins(:allocations)
          .where('allocations.user_id = ?', candidate_id)
          .where(id: current_meeting_ids_with_two_users)
          .first

      next unless meeting

      second_candidate_ids = allowed_ids - not_allowed_ids - [candidate_id]
      next unless Allocation.where(meeting_id: meeting.id, user_id: second_candidate_ids).any?

      return meeting.id
    end

    nil
  end

  def current_meeting_ids_with_two_users
    Allocation
      .joins(:meeting)
      .where('meetings.year = ? AND meetings.month = ?', year, month)
      .select("meeting_id, COUNT(1)")
      .group(:meeting_id)
      .having("COUNT(1) = 2")
      .pluck(:meeting_id)
  end

  def join_existing_meeting(user_id, meeting_id)
    Allocation.create!(meeting_id: meeting_id, user_id: user_id)
  end
end
