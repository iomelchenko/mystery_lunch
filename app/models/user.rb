# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  name            :string           not null
#  password_digest :string           not null
#  role            :integer          default("user"), not null
#  state           :integer          default("active"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  department_id   :bigint
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
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  GRAVATAR_URL = 'http://www.gravatar.com/avatar.php'

  has_secure_password
  has_one_attached :avatar

  belongs_to :department

  has_many :allocations
  has_many :meetings, through: :allocations

  enum state: { active: 0, inactive: 1 }
  enum role: { user: 0, admin: 1 }

  validates_presence_of :name, :state, :department, :role
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  scope :active, -> { where(state: :active) }

  def active?
    state == 'active'
  end

  def admin?
    role == 'admin'
  end
end
