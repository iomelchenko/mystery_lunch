# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  state         :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  department_id :bigint
#
# Indexes
#
#  index_users_on_department_id  (department_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#
class User < ApplicationRecord
  belongs_to :department

  has_many :allocations
  has_many :meetings, through: :allocations

  enum state: { active: 0, inactive: 1 }

  validates_presence_of :name, :state
end
