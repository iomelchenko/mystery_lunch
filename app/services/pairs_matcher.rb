# frozen_string_literal: true

class PairsMatcher
  attr_reader :allowed_allocations_builder,
              :excluded_users_buider,
              :meetings_creator,
              :odd_user_matcher,
              :month,
              :year,
              :odd_user_obj

  def initialize(
    month: Date.current.month,
    year: Date.current.year,
    allowed_allocations_builder: AllowedAllocationsBuilder,
    excluded_users_buider: ExcludedUsersBuilder,
    meetings_creator: MeetingsCreator,
    odd_user_matcher: OddUserMatcher
  )

    @month = month
    @year = year
    @allowed_allocations_builder = allowed_allocations_builder.new
    @excluded_users_buider = excluded_users_buider.new(month: month, year: year)
    @meetings_creator = meetings_creator.new(month: month, year: year)
    @odd_user_matcher = odd_user_matcher.new(month: month, year: year)
  end

  def allocate
    delete_meetings
    build_users_for_allocation
    build_not_allowed_for_allocation

    take_odd_user
    process_allocation
    allocate_odd_user
  end

  private

  def process_allocation
    loop do
      user_id, user_obj = min_by_allowed

      break if user_id.nil?

      matched_user_id = take_match(user_id, user_obj)

      break unless matched_user_id

      meetings_creator.call(user_id, matched_user_id)

      allowed_allocations_builder
        .remove_from_available(
          user_id: user_id,
          matched_user_id: matched_user_id
        )
    end
  end

  def take_odd_user
    return unless allowed_allocations_builder.users_for_allocation.count.odd?

    @odd_user_obj = min_by_allowed
    allowed_allocations_builder.remove_from_available(user_id: @odd_user_obj[0])
  end

  def build_users_for_allocation
    allowed_allocations_builder.call
  end

  def build_not_allowed_for_allocation
    excluded_users_buider.call(allowed_allocations_builder.all_candidates)
  end

  def min_by_allowed(ids = nil)
    if ids
      allowed_allocations_builder.users_for_allocation.select { |k, _v| ids.include?(k) }
    else
      allowed_allocations_builder.users_for_allocation
    end.min_by { |_k, v| v[:count] }
  end

  def take_match(user_id, user_obj)
    not_allowed = excluded_users_buider.not_allowed_for_allocation[user_id]
    min_by_allowed(user_obj[:allowed] - not_allowed)&.first
  end

  def delete_meetings
    meeting_ids_for_delete = Meeting.where(year: year, month: month).pluck(:id)

    Allocation.where(meeting_id: meeting_ids_for_delete).delete_all
    Meeting.where(id: meeting_ids_for_delete).delete_all
  end

  def allocate_odd_user
    return unless @odd_user_obj

    odd_user_id = @odd_user_obj[0]
    not_allowed_ids = excluded_users_buider.not_allowed_for_allocation[odd_user_id]
    allowed_ids = @odd_user_obj[1][:allowed]

    odd_user_matcher.call(odd_user_id, allowed_ids, not_allowed_ids)
  end
end
