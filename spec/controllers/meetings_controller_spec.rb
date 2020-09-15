# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingsController, type: :controller do
  let(:risk_department) { create :department, name: 'risk' }
  let(:data_department) { create :department, name: 'data' }

  let(:user) { create :user, department: risk_department }
  let(:user1) { create :user, department: data_department }

  let(:meeting) { create :meeting }
  let!(:allocation) { create :allocation, meeting: meeting, user: user }
  let!(:allocation2) { create :allocation, meeting: meeting, user: user1 }


  describe 'GET #index' do
    it 'assigns allocations' do
      get :index, params: {}

      data = assigns['data']

      expect(data[:iTotalRecords]).to eq(2)
      expect(data[:iTotalDisplayRecords]).to eq(2)
      expect(data[:aaData].map { |row| row[2] }).to match_array([user.name, user1.name])
    end
  end
end
