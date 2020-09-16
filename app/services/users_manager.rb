# frozen_string_literal: true

class UsersManager
  attr_reader :allowed_allocations_builder,
              :odd_user_matcher

  def initialize(
    allowed_allocations_builder: Matcher::AllowedAllocationsBuilder,
    odd_user_matcher: Matcher::OddUserMatcher
  )

    @allowed_allocations_builder = allowed_allocations_builder.new
    @odd_user_matcher = odd_user_matcher.new
  end

  def delete_from_meeting(user_id)
    allocation = allocation_for_deleting(user_id)
    meeting = allocation.meeting
    allocation.delete

    return if Allocation.where(meeting: meeting).count == 2

    match_remaining_user(meeting)
  end

  def add_new_user(user_id)
    odd_user_matcher.call(
      user_id,
      allowed_ids(user_id)
    )
  end

  private

  def match_remaining_user(meeting)
    remaining_allocation = meeting.allocations.first
    remaining_user_id = remaining_allocation.user_id
    remaining_allocation.delete

    odd_user_matcher.call(
      remaining_user_id,
      allowed_ids(remaining_user_id)
    )
  end

  def allocation_for_deleting(user_id)
    Allocation.with_current_meetings.find_by(user_id: user_id)
  end

  def allowed_ids(remaining_user_id)
    allowed_allocations_builder.call(remaining_user_id)

    allowed = allowed_allocations_builder
              .users_for_allocation[remaining_user_id]

    allowed ? allowed[:allowed] : []
  end
end
