# frozen_string_literal: true

require 'rails_helper'

describe UsersManager do
  let(:risk_department) { create :department, name: 'risk' }
  let(:sales_department) { create :department, name: 'sales' }
  let(:hr_department) { create :department, name: 'HR' }
  let(:data_department) { create :department, name: 'data' }

  let(:user1) { create :user, department: risk_department }
  let(:user2) { create :user, department: risk_department }
  let(:user3) { create :user, department: hr_department }
  let(:user4) { create :user, department: hr_department }
  let(:user6) { create :user, department: sales_department }
  let(:user7) { create :user, department: data_department }

  let(:meeting1) { create :meeting }
  let!(:allocation1) { create :allocation, meeting: meeting1, user: user1 }
  let!(:allocation2) { create :allocation, meeting: meeting1, user: user3 }

  let(:meeting2) { create :meeting }
  let!(:allocation3) { create :allocation, meeting: meeting2, user: user2 }
  let!(:allocation4) { create :allocation, meeting: meeting2, user: user4 }

  let(:meeting3) { create :meeting }
  let!(:allocation6) { create :allocation, meeting: meeting3, user: user6 }
  let!(:allocation7) { create :allocation, meeting: meeting3, user: user7 }

  describe '#delete_from_meeting' do
    context 'meeting with three users' do
      let(:user5) { create :user, department: sales_department }
      let!(:allocation5) { create :allocation, meeting: meeting1, user: user5 }

      it 'deletes the allocation' do
        user1.update!(state: :inactive)

        expect { subject.delete_from_meeting(user1.id) }.to change(Allocation, :count).by(-1)
      end
    end

    context 'meeting with two users' do
      it 'deletes the allocation' do
        user1.update!(state: :inactive)
        expect { subject.delete_from_meeting(user1.id) }.to change(Allocation, :count).by(-1)
      end

      it 'matched remaining user with another meeting' do
        meeting_id = Allocation.find_by_user_id(user3.id).meeting_id
        user1.update!(state: :inactive)

        subject.delete_from_meeting(user1.id)

        new_meeting_id = Allocation.find_by_user_id(user3.id).meeting_id

        expect(new_meeting_id).not_to eq(meeting_id)
        expect(new_meeting_id).to be_truthy
      end
    end
  end

  describe '#add_new_user' do
    context 'meeting with three users' do
      let!(:user5) { create :user, department: sales_department }

      it 'creates a new allocation' do
        user1.update!(state: :inactive)

        expect { subject.add_new_user(user5.id) }.to change(Allocation, :count).by(1)
      end
    end
  end
end
