# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Allocation.delete_all
Meeting.delete_all
User.delete_all
Department.delete_all

%w[operations
   sales
   marketing
   risk
   management
   finance
   HR
   development
   data].each do |depatment_name|
  Department.create!(name: depatment_name)
end

User.create!(
  name: 'ADMIN',
  department: Department.find_by_name('HR'),
  email: 'hr@example.com',
  password: 'Test1234',
  role: :admin
)

Department.pluck(:id).each do |department_id|
  1.upto(8).each do
    password = Faker::Internet.password(min_length: 6)

    User.create!(
      name: Faker::Name.first_name + ' ' + Faker::Name.last_name,
      department_id: department_id,
      email: Faker::Internet.email,
      password: password,
      password_confirmation: password
    )
  end
end

current_year = Date.current.year
current_month = Date.current.month

(current_month - 3).upto(current_month) do |month|
  1.upto(User.count / 2).each do
    Meeting.create!(
      year: current_year,
      month: month
    )
  end

  user_ids = User.pluck(:id).shuffle
  first_half_user_ids = user_ids[0...(User.count / 2)]
  last_half_user_ids = user_ids - first_half_user_ids

  Meeting.where(month: month).pluck(:id).each do |meeting_id|
    Allocation.create!(
      meeting_id: meeting_id,
      user_id: first_half_user_ids[0]
    )

    Allocation.create!(
      meeting_id: meeting_id,
      user_id: last_half_user_ids[0]
    )

    first_half_user_ids.shift
    last_half_user_ids.shift
  end
end