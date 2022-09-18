# frozen_string_literal: true

# == Schema Information
#
# Table name: departments
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Department, type: :model do
  it { is_expected.to have_many(:users) }

  it { is_expected.to validate_presence_of(:name) }
end
