# frozen_string_literal: true

require 'rails_helper'

describe AllowedAllocationsBuilder do
  let(:risk_department) { create :department, name: 'risk' }
  let(:sales_department) { create :department, name: 'sales' }
  let(:hr_department) { create :department, name: 'HR' }

  let!(:user1) { create :user, department: risk_department }
  let!(:user2) { create :user, department: risk_department }
  let!(:user3) { create :user, department: sales_department }
  let!(:user4) { create :user, department: sales_department }
  let!(:user5) { create :user, department: hr_department }

  let(:builder) { described_class.new }

  describe '#call' do
    let(:allocations_obj) do
      {
        user1.id.to_s => { :allowed => [user3.id.to_s, user4.id.to_s, user5.id.to_s], :count => 3 },
        user2.id.to_s => { :allowed => [user3.id.to_s, user4.id.to_s, user5.id.to_s], :count => 3 },
        user3.id.to_s => { :allowed => [user1.id.to_s, user2.id.to_s, user5.id.to_s], :count => 3 },
        user4.id.to_s => { :allowed => [user1.id.to_s, user2.id.to_s, user5.id.to_s], :count => 3 },
        user5.id.to_s => { :allowed => [user1.id.to_s, user2.id.to_s, user3.id.to_s, user4.id.to_s], :count => 4 }
      }
    end

    it 'creates a proper object' do
      builder.call

      expect(builder.users_for_allocation.count).to eq(5)

      User.all.each do |user|
        expect(builder.users_for_allocation[user.id.to_s]).to match(allocations_obj[user.id.to_s])
      end
    end
  end

  describe '#remove_from_available' do
    let(:allocations_obj) do
      {
        user2.id.to_s => { :allowed => [user4.id.to_s, user5.id.to_s], :count => 2 },
        user4.id.to_s => { :allowed => [user2.id.to_s, user5.id.to_s], :count => 2 },
        user5.id.to_s => { :allowed => [user2.id.to_s, user4.id.to_s], :count => 2 }
      }
    end

    let(:builder) { described_class.new }

    before do
      builder.call
    end

    it 'removes objects from hash object' do
      builder.remove_from_available(
        user_id: user1.id.to_s,
        matched_user_id: user3.id.to_s
      )

      expect(builder.users_for_allocation.count).to eq(3)

      User.all.each do |user|
        expect(builder.users_for_allocation[user.id.to_s]).to match(allocations_obj[user.id.to_s])
      end
    end
  end
end
