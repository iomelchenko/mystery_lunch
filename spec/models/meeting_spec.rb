# frozen_string_literal: true

# == Schema Information
#
# Table name: meetings
#
#  id         :bigint           not null, primary key
#  month      :integer          not null
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Meeting, type: :model do
  it { is_expected.to have_many(:users).through(:allocations) }
  it { is_expected.to have_many(:allocations) }

  it { is_expected.to validate_presence_of(:year) }
  it { is_expected.to validate_presence_of(:month) }
end
