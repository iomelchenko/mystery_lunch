# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  name            :string           not null
#  password_digest :string           not null
#  role            :integer          default("user"), not null
#  state           :integer          default("active"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  department_id   :bigint
#
# Indexes
#
#  index_users_on_department_id  (department_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#
require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:hr_department) { create :department, name: 'hr' }

  it { is_expected.to belong_to(:department) }
  it { is_expected.to have_many(:meetings).through(:allocations) }
  it { is_expected.to have_many(:allocations) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_presence_of(:department) }
  it { is_expected.to validate_presence_of(:role) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }

  context 'uniqueness validation' do
    subject { build :user, name: 'User Name' }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  context 'emails format validation' do
    context 'invalid email' do
      subject { build :user, name: 'User Name', email: 'ivalid_email' }
      it { is_expected.not_to be_valid }
    end

    context 'valid email' do
      subject { build :user, name: 'User Name', email: 'admin@example.com' }
      it { is_expected.to be_valid }
    end
  end

  context 'password length' do
    it 'build invalid user' do
      user = build :user, password: '1234'

      expect(user).not_to be_valid
    end

    it 'creates password validation error' do
      user = build :user, password: '1234'

      user.validate
      expect(user.errors[:password]).to eq(['is too short (minimum is 6 characters)'])
    end

    it 'builds valid user' do
      user = build :user, password: '123456'

      expect(user).to be_valid
    end
  end
end
