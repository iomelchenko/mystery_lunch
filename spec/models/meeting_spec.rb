# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Meeting, type: :model do
  it { is_expected.to have_many(:users).through(:allocations) }
  it { is_expected.to have_many(:allocations) }

  it { is_expected.to validate_presence_of(:year) }
  it { is_expected.to validate_presence_of(:month) }
end
