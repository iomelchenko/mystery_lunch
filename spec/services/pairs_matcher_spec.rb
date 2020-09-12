# frozen_string_literal: true

require 'rails_helper'

describe PairsMatcher do
  let(:risk_department) { create :department, name: 'risk' }
  let(:sales_department) { create :department, name: 'sales' }
  let(:hr_department) { create :department, name: 'HR' }

  let!(:user1) { create :user, department: risk_department }
  let!(:user2) { create :user, department: risk_department }
  let!(:user3) { create :user, department: sales_department }
  let!(:user4) { create :user, department: sales_department }
  let!(:user5) { create :user, department: hr_department }
  let!(:user6) { create :user, department: hr_department }

  describe '#allocate' do
    context 'without historical data' do
      context 'even users number' do
        it 'creates a proper meetings count' do
          subject.allocate

          expect(Meeting.count).to eq(3)
        end

        it 'creates a proper allocations count' do
          subject.allocate

          expect(Allocation.count).to eq(6)
        end

        it 'users department does not intersect' do
          subject.allocate

          Meeting.all.each do |meeting|
            expect(meeting.users.pluck(:department_id).uniq.count).to eq(2)
          end
        end
      end

      context 'allocates only active users' do
        before do
          user1.update(state: :inactive)
        end

        it 'creates a proper meetings count' do
          subject.allocate

          expect(Meeting.count).to eq(2)
        end

        it 'creates a proper allocations count' do
          subject.allocate

          expect(Allocation.count).to eq(5)
        end

        it 'users department does not intersect' do
          subject.allocate

          meetings_with_departments_count =
            Meeting.current.map do |meeting|
              meeting.users.pluck(:department_id).uniq.count
            end

          expect(meetings_with_departments_count).to match_array([2, 3])
        end
      end

      context 'odd users number' do
        let!(:user7) { create :user, department: hr_department }

        it 'creates a proper meetings count' do
          subject.allocate

          expect(Meeting.count).to eq(3)
        end

        it 'creates a proper allocations count' do
          subject.allocate

          expect(Allocation.count).to eq(7)
        end

        it 'users department does not intersect' do
          subject.allocate

          meetings_with_departments_count =
            Meeting.all.map do |meeting|
              meeting.users.pluck(:department_id).uniq.count
            end

          expect(meetings_with_departments_count).to match_array([2, 2, 3])
        end
      end
    end

    context 'with historical data' do
      let(:historical_date1) { 3.month.ago.at_beginning_of_month }
      let(:historical_date2) { 2.month.ago.at_beginning_of_month }
      let(:historical_date3) { 1.month.ago.at_beginning_of_month }

      let(:meeting1) { create :meeting, year: historical_date1.year, month: historical_date1.month }
      let!(:allocation1) { create :allocation, meeting: meeting1, user: user1 }
      let!(:allocation2) { create :allocation, meeting: meeting1, user: user3 }

      let(:meeting2) { create :meeting, year: historical_date1.year, month: historical_date1.month }
      let!(:allocation3) { create :allocation, meeting: meeting2, user: user2 }
      let!(:allocation4) { create :allocation, meeting: meeting2, user: user5 }

      let(:meeting3) { create :meeting, year: historical_date2.year, month: historical_date2.month }
      let!(:allocation5) { create :allocation, meeting: meeting3, user: user4 }
      let!(:allocation6) { create :allocation, meeting: meeting3, user: user6 }

      context 'even users number' do
        it 'creates a proper meetings count' do
          subject.allocate

          expect(Meeting.current.count).to eq(3)
        end

        it 'creates a proper allocations count' do
          subject.allocate

          expect(Allocation.with_current_meetings.count).to eq(6)
        end

        it 'users department does not intersect' do
          subject.allocate

          Meeting.current.each do |meeting|
            expect(meeting.users.pluck(:department_id).uniq.count).to eq(2)
          end
        end
      end

      context 'odd users number' do
        let!(:user7) { create :user, department: hr_department }
        let!(:odd_allocation) { create :allocation, meeting: meeting1, user: user7 }

        it 'creates a proper meetings count' do
          subject.allocate

          expect(Meeting.current.count).to eq(3)
        end

        it 'creates a proper allocations count' do
          subject.allocate

          expect(Allocation.with_current_meetings.count).to eq(7)
        end

        it 'users department does not intersect' do
          subject.allocate

          meetings_with_departments_count =
            Meeting.current.map do |meeting|
              meeting.users.pluck(:department_id).uniq.count
            end

          expect(meetings_with_departments_count).to match_array([2, 2, 3])
        end
      end
    end
  end
end
