# frozen_string_literal: true

require 'rails_helper'

describe OddUserMatcher do
  let(:risk_department) { create :department, name: 'risk' }
  let(:sales_department) { create :department, name: 'sales' }
  let(:development_department) { create :department, name: 'development' }
  let(:hr_department) { create :department, name: 'HR' }

  let(:user1) { create :user, department: risk_department }
  let(:user2) { create :user, department: sales_department }
  let(:user3) { create :user, department: hr_department }

  let(:meeting) { create :meeting }
  let!(:allocation1) { create :allocation, meeting: meeting, user: user1 }
  let!(:allocation2) { create :allocation, meeting: meeting, user: user2 }

  let(:allowed_ids) { [user1.id, user2.id] }

  context 'for meeting with two users' do
    it 'creates a new allocation' do
      expect { subject.call(user3.id, allowed_ids) }.to change(Allocation, :count).by(1)
    end

    it 'creates a proper allocations entity' do
      subject.call(user3.id, allowed_ids)
      created_allocation = Allocation.last

      expect(created_allocation.user_id).to eq(user3.id)
      expect(created_allocation.meeting_id).to eq(meeting.id)
    end

    it 'does not create a new allocation in case of only one allowed id' do
      allowed_ids = [user1.id]

      expect { subject.call(user3.id, allowed_ids) }.to change(Allocation, :count).by(0)
    end
  end

  context 'for meeting with three users' do
    let(:user4) { create :user, department: development_department }
    let!(:allocation3) { create :allocation, meeting: meeting, user: user4 }

    it 'does not create a new allocation' do
      allowed_ids = [user1.id, user2.id, user4.id]

      expect { subject.call(user3.id, allowed_ids) }.to change(Allocation, :count).by(0)
    end
  end
end
