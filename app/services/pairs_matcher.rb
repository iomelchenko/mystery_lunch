# frozen_string_literal: true

class PairsMatcher
  attr_reader :users_for_allocation, :month, :year

  def initialize(params={})
    @users_for_allocation ||= build_users_for_allocation
    @month = params[:month] || Date.current.month
    @year = params[:year] || Date.current.year
  end

  def allocate
    delete_meetings
    process_allocation
  end

  private

  def process_allocation
    loop do
      user_id, user_obj = min_by_allowed

      break if user_id.nil?
      break if user_obj[:allowed].empty? # Latest odd user!!!!!!!!!!!!!!!!
      matched_user_id = take_match(user_obj)

      meeting_params = {
        user_id: user_id,
        matched_user_id: matched_user_id
      }

      create_meeting(meeting_params)
      remove_from_available(meeting_params)
    end
  end

  def build_users_for_allocation
    sql = "
      SELECT u1.id AS first_el, u2.id AS second_el
        FROM users AS u1
  CROSS JOIN users AS u2
       WHERE u1.id != u2.id
         AND u1.department_id != u2.department_id;"

    cross_join = ActiveRecord::Base.connection.execute(sql).to_a

    pair_cases = cross_join.map { |row| [row['first_el'], row['second_el']].sort }.uniq
    all_candidates = pair_cases.flatten.uniq.sort

    all_candidates.each_with_object({}) do |user_id, hsh|
      matches = Array.new

      pair_cases.each do |pair|
        if user_id == pair[0]
          matches << pair[1]
        elsif user_id == pair[1]
          matches << pair[0]
        end
      end

      matches.uniq!
      hsh["#{user_id}"] = { allowed: matches, count: matches.count }
    end
  end

  def min_by_allowed(ids=nil)
    if ids
      users_for_allocation.select { |k, _v| ids.include?(k.to_i) }
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
    [meeting_params[:user_id], meeting_params[:matched_user_id]].each do |user_id|
      users_for_allocation.delete(user_id)

      users_for_allocation.each do |k, v|
        v[:allowed].delete(user_id.to_i)
        v[:count] = v[:allowed].count
      end
    end
  end
end
