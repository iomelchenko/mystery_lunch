# frozen_string_literal: true

FactoryBot.define do
  factory :meeting, class: Meeting do
    month { Date.current.month }
    year  { Date.current.year }
  end
end
