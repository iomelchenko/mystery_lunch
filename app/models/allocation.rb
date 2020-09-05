# frozen_string_literal: true

# == Schema Information
#
# Table name: allocations
#
#  id         :bigint           not null, primary key
#  meeting_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_allocations_on_meeting_id  (meeting_id)
#  index_allocations_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (meeting_id => meetings.id)
#  fk_rails_...  (user_id => users.id)
#
class Allocation < ApplicationRecord
  belongs_to :meeting
  belongs_to :user

  scope :with_current_meetings, (lambda do
    joins(:meeting)
      .merge(Meeting.current)
      .includes(:meeting, user: :department)
  end)

  scope :with_past_meetings, (lambda do
    joins(:meeting)
      .merge(Meeting.past)
      .includes(:meeting, user: :department)
  end)
end
