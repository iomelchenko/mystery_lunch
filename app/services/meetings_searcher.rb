# frozen_string_literal: true

class MeetingsSearcher
  attr_reader :params, :allocations

  def initialize(params, scope)
    @params = params
    @allocations = define_scope(scope)
  end

  def call
    allocations.then { |alloc| params[:sSearch].present? ? filter(alloc) : alloc }
      .includes(:meeting, user: :department)
      .includes(user: { avatar_attachment: :blob })
      .order(meeting_id: :desc)
      .page(page)
      .per_page(per_page)
  end

  private

  def define_scope(scope)
    if params[:pastMeetings] == '1'
      scope.with_past_meetings
    else
      scope.with_current_meetings
    end
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def filter(allocations)
    # Need to redesign with postgres full text search
    # due to poor performance (LIKE .. OR LIKE ..) query

    allocations
      .where(
        "EXISTS (SELECT 1
                   FROM allocations AS al
                   JOIN users AS u ON u.id = al.user_id
                   JOIN departments AS d ON u.department_id = d.id
                  WHERE al.meeting_id = allocations.meeting_id
                    AND (d.name ILIKE :search OR u.name ILIKE :search))",
        search: "%#{params[:sSearch]}%"
      )

  end
end
