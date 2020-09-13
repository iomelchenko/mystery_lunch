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

  describe '#call' do
    let(:allocations_obj) do
      {
        user1.id => { :allowed => [user3.id, user4.id, user5.id], :count => 3 },
        user2.id => { :allowed => [user3.id, user4.id, user5.id], :count => 3 },
        user3.id => { :allowed => [user1.id, user2.id, user5.id], :count => 3 },
        user4.id => { :allowed => [user1.id, user2.id, user5.id], :count => 3 },
        user5.id => { :allowed => [user1.id, user2.id, user3.id, user4.id], :count => 4 }
      }
    end

    it 'creates a proper object' do
      subject.call

      expect(subject.users_for_allocation.count).to eq(5)

      User.all.each do |user|
        allowed = subject.users_for_allocation[user.id]
        expected = allocations_obj[user.id]
        next unless allowed

        expect(allowed[:allowed]).to match_array(expected[:allowed])
        expect(allowed[:count]).to eq(expected[:count])
      end
    end
  end

  describe '#remove_from_available' do
    let(:allocations_obj) do
      {
        user2.id => { :allowed => [user4.id, user5.id], :count => 2 },
        user4.id => { :allowed => [user2.id, user5.id], :count => 2 },
        user5.id => { :allowed => [user2.id, user4.id], :count => 2 }
      }
    end

    before do
      subject.call
    end

    it 'removes objects from hash object' do
      subject.remove_from_available(
        user_id: user1.id,
        matched_user_id: user3.id
      )

      expect(subject.users_for_allocation.count).to eq(3)

      User.all.each do |user|
        allowed = subject.users_for_allocation[user.id]
        expected = allocations_obj[user.id]
        next unless allowed

        expect(allowed[:allowed]).to match_array(expected[:allowed])
        expect(allowed[:count]).to eq(expected[:count])
      end
    end
  end
end
