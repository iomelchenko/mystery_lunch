# frozen_string_literal: true

# == Schema Information
#
# Table name: meetings
#
#  id         :bigint           not null, primary key
#  month      :integer          not null
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Meeting < ApplicationRecord
  FORBIDDEN_PAIRS_PERIOD_IN_MONTHS = 3

  has_many :allocations
  has_many :users, through: :allocations

  validates_presence_of :year, :month

  scope :current, -> { where('year = ? AND month = ?', Date.current.year, Date.current.month) }

  scope :past, (lambda do
    where('(year = ? AND month < ?) OR year < ?', Date.current.year, Date.current.month, Date.current.year)
  end)
end
