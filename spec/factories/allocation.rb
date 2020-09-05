# frozen_string_literal: true

FactoryBot.define do
  factory :allocation, class: Allocation do
    user { User.first }
    meeting { Meeting.first }
  end
end
