# frozen_string_literal: true

require 'rails_helper'

describe MeetingsCreator do
  let(:risk_department) { create :department, name: 'risk' }
  let(:sales_department) { create :department, name: 'sales' }

  let(:user1) { create :user, department: risk_department }
  let(:user2) { create :user, department: sales_department }

  it 'creates a meeting entity' do
    expect { subject.call(user1.id, user2.id) }.to change(Meeting, :count).by(1)
  end

  it 'creates allocations entities' do
    expect { subject.call(user1.id, user2.id) }.to change(Allocation, :count).by(2)
  end

  it 'created entities have proper attributes' do
    subject.call(user1.id, user2.id)
    meeting = Meeting.last

    expect(meeting.year).to eq(Date.current.year)
    expect(meeting.month).to eq(Date.current.month)

    expect(meeting.allocations.map(&:user_id)).to match_array([user1.id, user2.id])
  end
end
