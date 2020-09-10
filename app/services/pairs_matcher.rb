# frozen_string_literal: true

class PairsMatcher
  attr_reader :users_for_allocation, :month, :year, :odd_user_obj

  def initialize(params={})
    @month = params[:month] || Date.current.month
    @year = params[:year] || Date.current.year
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
      user_id, user_obj = min_by_allowed

      break if user_id.nil?

      matched_user_id = take_match(user_obj)

      meeting_params = buid_meeting_params(user_id, matched_user_id)

      create_meeting(meeting_params)
      remove_from_available(meeting_params)
    end
  end

  def take_odd_user
    return unless users_for_allocation.count.odd?

    @odd_user_obj = min_by_allowed
    remove_from_available(user_id: @odd_user_obj[0])
  end

  def build_users_for_allocation
    cross_users = ActiveRecord::Base.connection.execute(cross_users_statement).to_a

    pair_cases = cross_users.map { |row| [row['first_el'], row['second_el']].sort }.uniq
    all_candidates = pair_cases.flatten.uniq

    @users_for_allocation =
      all_candidates.each_with_object({}) do |user_id, hsh|
        matches = Array.new

        pair_cases.each do |pair|
          if user_id == pair[0]
            matches << pair[1].to_s
          elsif user_id == pair[1]
            matches << pair[0].to_s
          end
        end

        matches.uniq!
        hsh["#{user_id}"] = { allowed: matches, count: matches.count }
      end
  end

  def min_by_allowed(ids=nil)
    if ids
      users_for_allocation.select { |k, _v| ids.include?(k) }
    else
      users_for_allocation
    end.min_by { |_k, v| v[:count] }
  end

  def take_match(user_obj)
    min_by_allowed(user_obj[:allowed])[0]
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

  def remove_from_available(meeting_params)
    user_id = meeting_params[:user_id]
    matched_user_id = meeting_params[:matched_user_id]

    users_for_allocation.delete(user_id)
    users_for_allocation.delete(matched_user_id)

    users_for_allocation.each do |k, v|
      v[:allowed].delete(user_id)
      v[:allowed].delete(matched_user_id)

      v[:count] = v[:allowed].count
    end
  end

  def buid_meeting_params(user_id, matched_user_id)
    {
      user_id: user_id,
      matched_user_id: matched_user_id
    }
  end

  def cross_users_statement
    "SELECT u1.id AS first_el, u2.id AS second_el
       FROM users AS u1
      CROSS JOIN users AS u2
      WHERE u1.id != u2.id
        AND u1.department_id != u2.department_id;"
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
