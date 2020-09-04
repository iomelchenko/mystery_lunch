# frozen_string_literal: true

class AddUsersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.references :department, index: true, foreign_key: true
      t.string :name, null: false
      t.integer :state, null: false
      t.timestamps
    end
  end
end
