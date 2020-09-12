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

puts "-----> Generated #{Department.count} departments."

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

puts "-----> Generated #{User.count} users."

Rake::Task['initialise:meetings_seeds'].invoke
