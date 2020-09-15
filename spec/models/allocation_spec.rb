# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Allocation, type: :model do
  it { is_expected.to belong_to(:meeting) }
  it { is_expected.to belong_to(:user) }
end
