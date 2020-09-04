# frozen_string_literal: true

class AddMeetingsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :meetings do |t|
      t.integer :year, null: false
      t.integer :month, null: false
      t.timestamps
    end
  end
end
