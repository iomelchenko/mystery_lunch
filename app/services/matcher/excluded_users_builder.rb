# frozen_string_literal: true

module Matcher
  class ExcludedUsersBuilder
    attr_reader :not_allowed_for_allocation, :month, :year

    def initialize(month: Date.current.month, year: Date.current.year)
      @month = month
      @year = year
    end

    def call(all_candidates)
      build_not_allowed_for_allocation(all_candidates)
    end

    private

    def build_not_allowed_for_allocation(all_candidates)
      cross_users = ActiveRecord::Base.connection.execute(historycal_cross_join_statement(history_meeting_ids)).to_a

      pair_cases = cross_users.map { |row| [row['first_el'], row['second_el']].sort }.uniq

      @not_allowed_for_allocation =
        all_candidates
        .each_with_object({}) do |user_id, hsh|
          matches = []

          pair_cases.each do |pair|
            if user_id == pair[0]
              matches << pair[1]
            elsif user_id == pair[1]
              matches << pair[0]
            end
          end

          matches.uniq!
          hsh[user_id] = matches
        end
    end

    def historycal_cross_join_statement(meeting_ids)
      meeting_ids = [-1] if meeting_ids.empty?

      "SELECT a1.user_id AS first_el, a2.user_id AS second_el
         FROM allocations AS a1
        CROSS JOIN allocations AS a2
        WHERE a1.meeting_id = a2.meeting_id
          AND a1.user_id != a2.user_id
          AND a1.meeting_id IN (#{meeting_ids.join(',')});"
    end

    def history_meeting_ids
      first_date = ::Meeting::FORBIDDEN_PAIRS_PERIOD_IN_MONTHS.month.ago.at_beginning_of_month
      last_date = Date.new(year, month, 1).at_end_of_month

      Allocation
        .joins(:meeting)
        .where('make_date(meetings.year, meetings.month, 1) >= ?', first_date)
        .where('make_date(meetings.year, meetings.month, 1) < ?', last_date)
        .pluck(:meeting_id)
    end
  end
end
