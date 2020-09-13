# frozen_string_literal: true

require 'rails_helper'

describe ExcludedUsersBuilder do
  let(:risk_department) { create :department, name: 'risk' }
  let(:sales_department) { create :department, name: 'sales' }
  let(:hr_department) { create :department, name: 'HR' }

  let(:user1) { create :user, department: risk_department }
  let(:user2) { create :user, department: risk_department }
  let(:user3) { create :user, department: sales_department }
  let(:user4) { create :user, department: sales_department }
  let(:user5) { create :user, department: hr_department }
  let(:user6) { create :user, department: hr_department }
  let(:user7) { create :user, department: hr_department }

  let(:last_date) { Date.current - 2.month }

  let(:meeting1) { create :meeting, year: last_date.year, month: last_date.month }
  let(:meeting2) { create :meeting, year: last_date.year, month: last_date.month }
  let(:meeting3) { create :meeting, year: last_date.year, month: last_date.month }
  let(:meeting4) { create :meeting, year: (last_date - 1.month).year, month: (last_date - 1.month).month }

  let!(:allocation1) { create :allocation, meeting: meeting1, user: user1 }
  let!(:allocation2) { create :allocation, meeting: meeting1, user: user2 }
  let!(:allocation3) { create :allocation, meeting: meeting2, user: user3 }
  let!(:allocation4) { create :allocation, meeting: meeting2, user: user4 }
  let!(:allocation5) { create :allocation, meeting: meeting3, user: user5 }
  let!(:allocation6) { create :allocation, meeting: meeting3, user: user6 }
  let!(:allocation7) { create :allocation, meeting: meeting3, user: user7 }

  let!(:allocation8) { create :allocation, meeting: meeting4, user: user5 }
  let!(:allocation9) { create :allocation, meeting: meeting4, user: user1 }
  let!(:allocation10) { create :allocation, meeting: meeting4, user: user3 }

  let(:all_candidates) { User.active.map(&:id) }

    let(:not_allowed_obj) do
      {
        user1.id => [user2.id, user3.id, user5.id],
        user2.id => [user1.id],
        user3.id => [user1.id, user4.id, user5.id],
        user4.id => [user3.id],
        user5.id => [user1.id, user3.id, user6.id, user7.id],
        user6.id => [user5.id, user7.id],
        user7.id => [user5.id, user6.id]
      }
    end

  describe '#call' do
    it 'creates a proper object' do
      subject.call(all_candidates)

      expect(subject.not_allowed_for_allocation.count).to eq(7)

      User.all.each do |user|
        expect(subject.not_allowed_for_allocation[user.id]).to match_array(not_allowed_obj[user.id])
      end
    end
  end
end
