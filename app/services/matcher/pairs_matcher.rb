# frozen_string_literal: true

module Matcher
  class PairsMatcher
    attr_reader :allowed_allocations_builder,
                :meetings_creator,
                :odd_user_matcher,
                :month,
                :year,
                :odd_user_obj

    def initialize(
      month: Date.current.month,
      year: Date.current.year,
      allowed_allocations_builder: Matcher::AllowedAllocationsBuilder,
      meetings_creator: MeetingsCreator,
      odd_user_matcher: Matcher::OddUserMatcher
    )

      @month = month
      @year = year
      @allowed_allocations_builder = allowed_allocations_builder.new
      @meetings_creator = meetings_creator.new(month: month, year: year)
      @odd_user_matcher = odd_user_matcher.new(month: month, year: year)
    end

    def allocate
      delete_meetings
      build_users_for_allocation

      take_odd_user
      process_allocation
      allocate_odd_user
    end

    private

    def process_allocation
      loop do
        user_id, user_obj = take_user_id

        break if user_id.nil?

        matched_user_id = take_user_id(user_obj[:allowed])&.first

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

      @odd_user_obj = take_user_id([allowed_allocations_builder.users_for_allocation.keys.shuffle[-1]])
      allowed_allocations_builder.remove_from_available(user_id: @odd_user_obj[0])
    end

    def build_users_for_allocation
      allowed_allocations_builder.call
    end

    def take_user_id(ids = nil)
      return if !ids.nil? && ids.empty?

      allowed = if ids.present?
                   allowed_allocations_builder.users_for_allocation.select { |k, _v| ids.include?(k) }
                 else
                   allowed_allocations_builder.users_for_allocation
                 end

      return unless allowed.present?
      return [allowed.keys[0], allowed.values[0]] if allowed.count == 1

      min_count = allowed.min_by { |_k, v| v[:count] }[1][:count]
      allowed
        .map { |k, v| [k, v] if v[:count] == min_count }
        .compact
        .shuffle[-1]
    end

    def delete_meetings
      meeting_ids_for_delete = Meeting.where(year: year, month: month).pluck(:id)

      Allocation.where(meeting_id: meeting_ids_for_delete).delete_all
      Meeting.where(id: meeting_ids_for_delete).delete_all
    end

    def allocate_odd_user
      return unless @odd_user_obj

      odd_user_id = @odd_user_obj[0]
      allowed_ids = @odd_user_obj[1][:allowed]

      odd_user_matcher.call(odd_user_id, allowed_ids)
    end
  end
end
