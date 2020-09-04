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

Department.pluck(:id).each do |department_id|
  1.upto(8).each do
    User.create!(
      name: Faker::Name.first_name + ' ' + Faker::Name.last_name,
      department_id: department_id,
      state: :active
    )
  end
end

year = Date.current.year
month = Date.current.month

1.upto(User.count / 2).each do
  Meeting.create!(
    year: year,
    month: month
  )
end

user_ids = User.pluck(:id).shuffle
first_half_user_ids = user_ids[0...(User.count / 2)]
last_half_user_ids = user_ids - first_half_user_ids

Meeting.pluck(:id).each do |meeting_id|
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
