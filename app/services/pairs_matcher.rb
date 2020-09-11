# frozen_string_literal: true

class PairsMatcher
  attr_reader :allowed_allocations_builder,
              :excluded_users_buider,
              :month,
              :year,
              :odd_user_obj

  def initialize(
        month: Date.current.month,
        year: Date.current.year,
        allowed_allocations_builder: AllowedAllocationsBuilder,
        excluded_users_buider: ExcludedUsersBuilder
      )

    @month = month
    @year = year
    @allowed_allocations_builder = allowed_allocations_builder.new
    @excluded_users_buider = excluded_users_buider.new(month: month, year: year)
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

      meeting_params = buid_meeting_params(user_id, matched_user_id)
      create_meeting(meeting_params)
      allowed_allocations_builder.remove_from_available(meeting_params)
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

  def min_by_allowed(ids=nil)
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

  def allocate_odd_user
    return unless @odd_user_obj

    odd_user_id = @odd_user_obj[0]
    allowed_ids = @odd_user_obj[1][:allowed]

    allowed_ids.each do |allowed_id|
      meeting =
        Meeting
          .where(year: year, month: month)
          .joins(:allocations)
          .where('allocations.user_id = ?', allowed_id)
          .first

      next unless Allocation.where(meeting_id: meeting.id, user_id: (allowed_ids - [allowed_id])).any?

      join_existing_meeting(odd_user_id, meeting.id)

      break
    end
  end

  def join_existing_meeting(user_id, meeting_id)
    Allocation.create!(meeting_id: meeting_id, user_id: user_id)
  end
end
