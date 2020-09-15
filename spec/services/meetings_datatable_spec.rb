# frozen_string_literal: true

require 'rails_helper'

describe MeetingsDatatable do
  let(:risk_department) { create :department, name: 'risk' }
  let(:sales_department) { create :department, name: 'sales' }

  let(:user1) { create :user, department: risk_department }
  let(:user2) { create :user, department: sales_department }
  let(:user3) { create :user, department: risk_department }
  let(:user4) { create :user, department: sales_department }

  let(:meeting1) { create :meeting }
  let(:meeting2) { create :meeting }

  let!(:allocation1) { create :allocation, meeting: meeting1, user: user1 }
  let!(:allocation2) { create :allocation, meeting: meeting1, user: user2 }
  let!(:allocation3) { create :allocation, meeting: meeting2, user: user3 }
  let!(:allocation4) { create :allocation, meeting: meeting2, user: user4 }

  let(:view_object) { OpenStruct.new(params: { sEcho: 1 }) }
  let(:current_allocations) { Allocation.with_current_meetings }

  let(:avatar_url) { 'http://www.gravatar.com' }

  before do
    allow_any_instance_of(described_class).to receive(:get_avatar_url).and_return(avatar_url)
  end

  it 'returns valid json object for datatable' do
    datatable_json = described_class.new(view_object, current_allocations).call
    data = datatable_json[:aaData]

    expect(datatable_json[:sEcho]).to eql(view_object[:params][:sEcho])
    expect(datatable_json[:iTotalRecords]).to eql(Allocation.count)
    expect(datatable_json[:iTotalDisplayRecords]).to eql(Allocation.count)

    expect(data).to include(
      [
        "Mystery pair #{meeting1.id}",
        "#{Date.current.month}/#{Date.current.year}",
        user1.name,
        user1.department.name,
        avatar_url
      ]
    )

    expect(data).to include(
      [
        "Mystery pair #{meeting1.id}",
        "#{Date.current.month}/#{Date.current.year}",
        user2.name,
        user2.department.name,
        avatar_url
      ]
    )

    expect(data).to include(
      [
        "Mystery pair #{meeting2.id}",
        "#{Date.current.month}/#{Date.current.year}",
        user3.name,
        user3.department.name,
        avatar_url
      ]
    )

    expect(data).to include(
      [
        "Mystery pair #{meeting2.id}",
        "#{Date.current.month}/#{Date.current.year}",
        user4.name,
        user4.department.name,
        avatar_url
      ]
    )
  end
end
