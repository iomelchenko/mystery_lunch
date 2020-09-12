# frozen_string_literal: true

class MeetingsDatatable
  include ERB::Util
  include Rails.application.routes.url_helpers

  attr_reader :collection
  delegate :params, to: :@view

  def initialize(view, collection)
    @view = view
    @collection = collection
  end

  def call
    as_json
  end

  private

  def as_json(_options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: collection_count,
      iTotalDisplayRecords: collection_count,
      aaData: data
    }
  end

  def data
    collection.map do |row|
      [
        html_escape(meeting_name(row.meeting.id)),
        html_escape(meeting_month(row.meeting.year, row.meeting.month)),
        html_escape(row.user.name),
        html_escape(row.user.department.name),
        html_escape(get_avatar_url(row.user))
      ]
    end
  end

  def meeting_month(year, month)
    month.to_s + '/' + year.to_s
  end

  def meeting_name(id)
    "Mystery pair #{id}"
  end

  def collection_count
    @collection_count ||= collection.count
  end

  def get_avatar_url(user)
    return gravatar(user) unless user.avatar.present?

    polymorphic_path(user.avatar.variant(resize: '75x75'))
  end

  def gravatar(user)
    "#{::User::GRAVATAR_URL}?gravatar_id=#{Digest::MD5.hexdigest(user.email)}?d=wavatar"
  end
end
