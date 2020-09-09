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
          described_class.new.allocate

          expect(Meeting.count).to eq(3)
        end

        it 'creates a proper allocations count' do
          described_class.new.allocate

          expect(Allocation.count).to eq(6)
        end

        it 'users department does not intersect' do
          described_class.new.allocate

          Meeting.all.each do |meeting|
            expect(meeting.users.pluck(:department_id).uniq.count).to be > 1
          end
        end
      end
    end
  end
end
