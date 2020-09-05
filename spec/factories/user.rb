# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: User do
    name { Faker::Name.first_name + ' ' + Faker::Name.last_name }
    state { :active }
    department { Department.first }
  end
end
