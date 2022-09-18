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
require 'rails_helper'

RSpec.describe Allocation, type: :model do
  it { is_expected.to belong_to(:meeting) }
  it { is_expected.to belong_to(:user) }
end
