# frozen_string_literal: true

class AllowedAllocationsBuilder
  attr_reader :all_candidates, :users_for_allocation

  def call(user_id = nil)
    pair_cases, @all_candidates = select_all_candidates(user_id)
    build_users_for_allocation(all_candidates, pair_cases)
  end

  def remove_from_available(meeting_params)
    user_id = meeting_params[:user_id]
    matched_user_id = meeting_params[:matched_user_id]

    users_for_allocation.delete(user_id)
    users_for_allocation.delete(matched_user_id)

    users_for_allocation.each do |_k, v|
      v[:allowed].delete(user_id)
      v[:allowed].delete(matched_user_id)

      v[:count] = v[:allowed].count
    end
  end

  private

  def select_all_candidates(user_id)
    cross_users = ActiveRecord::Base.connection.execute(cross_users_statement(user_id)).to_a

    pair_cases = cross_users.map { |row| [row['first_el'], row['second_el']].sort }.uniq
    [pair_cases, pair_cases.flatten.uniq]
  end

  def build_users_for_allocation(all_candidates, pair_cases)
    @users_for_allocation =
      all_candidates.each_with_object({}) do |user_id, hsh|
        matches = []

        pair_cases.each do |pair|
          if user_id == pair[0]
            matches << pair[1].to_s
          elsif user_id == pair[1]
            matches << pair[0].to_s
          end
        end

        matches.uniq!
        hsh[user_id.to_s] = { allowed: matches, count: matches.count }
      end
  end

  def cross_users_statement(user_id)
    user_id ||= 'NULL'

    "SELECT u1.id AS first_el, u2.id AS second_el
       FROM users AS u1
      CROSS JOIN users AS u2
      WHERE u1.id != u2.id
        AND u1.state = 0
        AND u2.state = 0
        AND (u1.id = COALESCE(#{user_id}, u1.id) OR u2.id = COALESCE(#{user_id}, u2.id))
        AND u1.department_id != u2.department_id;"
  end
end
