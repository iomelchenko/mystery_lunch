# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Department, type: :model do
  it { is_expected.to have_many(:users) }

  it { is_expected.to validate_presence_of(:name) }
end
