# frozen_string_literal: true

# == Schema Information
#
# Table name: allocations
#
#  id          :bigint           not null, primary key
#  meetings_id :bigint
#  users_id    :bigint
#
# Indexes
#
#  index_allocations_on_meetings_id  (meetings_id)
#  index_allocations_on_users_id     (users_id)
#
# Foreign Keys
#
#  fk_rails_...  (meetings_id => meetings.id)
#  fk_rails_...  (users_id => users.id)
#
class Allocation < ApplicationRecord
  belongs_to :meeting
  belongs_to :user
end
