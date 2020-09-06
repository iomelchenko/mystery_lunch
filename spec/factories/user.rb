# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: User do
    name { Faker::Name.first_name + ' ' + Faker::Name.last_name }
    state { :active }
    department { Department.first }
    password { Faker::Internet.password(min_length: 6) }
    email  { Faker::Internet.email }
  end
end
