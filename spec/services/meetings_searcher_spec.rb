# frozen_string_literal: true

require 'rails_helper'

describe MeetingsSearcher do
  let(:risk_department) { create :department, name: 'risk' }
  let(:sales_department) { create :department, name: 'sales' }
  let(:hr_department) { create :department, name: 'HR' }

  let(:user1) { create :user, department: risk_department }
  let(:user2) { create :user, department: sales_department }
  let(:user3) { create :user, department: risk_department }
  let(:user4) { create :user, department: sales_department }
  let(:user5) { create :user, department: hr_department }
  let(:user6) { create :user, department: risk_department }

  let(:meeting1) { create :meeting }
  let(:meeting2) { create :meeting }
  let(:meeting3) { create :meeting }
  let(:past_meeting) { create :meeting, year: Date.current.year - 1 }

  let!(:allocation1) { create :allocation, meeting: meeting1, user: user1 }
  let!(:allocation2) { create :allocation, meeting: meeting1, user: user2 }
  let!(:allocation3) { create :allocation, meeting: meeting2, user: user3 }
  let!(:allocation4) { create :allocation, meeting: meeting2, user: user4 }
  let!(:allocation5) { create :allocation, meeting: meeting3, user: user5 }
  let!(:allocation6) { create :allocation, meeting: meeting3, user: user6 }
  let!(:past_allocation1) { create :allocation, meeting: past_meeting, user: user1 }
  let!(:past_allocation2) { create :allocation, meeting: past_meeting, user: user2 }

  let(:all_allocations) { Allocation.all }

  context 'users filtering' do
    it 'returns valid search results by user name' do
      search_result = described_class.new({ sSearch: user1.name }, all_allocations).call

      expect(search_result.count).to eql(2)
      expect(search_result).to match_array(Allocation.with_current_meetings.where(meeting: meeting1))
    end

    it 'returns valid search results by query string' do
      query_string = user5.name.upcase[1..(user5.name.length - 2)]
      search_result = described_class.new({ sSearch: query_string }, all_allocations).call

      expect(search_result.count).to eql(2)
      expect(search_result).to match_array(Allocation.where(meeting: meeting3))
    end
  end

  context 'departments filtering' do
    it 'returns valid search results for risk department' do
      search_result = described_class.new({ sSearch: risk_department.name }, all_allocations).call

      expect(search_result.count).to eql(6)
      expect(search_result).to match_array(Allocation.where(meeting_id: [meeting1.id, meeting2.id, meeting3.id]))
    end

    it 'returns valid search results for sales department' do
      search_result = described_class.new({ sSearch: sales_department.name }, all_allocations).call

      expect(search_result.count).to eql(4)
      expect(search_result).to match_array(Allocation.where(meeting_id: [meeting1.id, meeting2.id]))
    end

    it 'returns valid search results for hr department' do
      search_result = described_class.new({ sSearch: hr_department.name }, all_allocations).call

      expect(search_result.count).to eql(2)
      expect(search_result).to match_array(Allocation.where(meeting: meeting3))
    end
  end

  context 'current/past meetings filtering' do
    it 'returns valid search results for current meetings filter' do
      search_result = described_class.new({}, all_allocations).call

      expect(search_result.count).to eql(6)
      expect(search_result).to match_array(Allocation.where(meeting_id: [meeting1.id, meeting2.id, meeting3.id]))
    end

    it 'returns valid search results for past meetings filter' do
      search_result = described_class.new({ pastMeetings: '1' }, all_allocations).call

      expect(search_result.count).to eql(2)
      expect(search_result).to match_array(Allocation.where(meeting: past_meeting))
    end
  end
end
