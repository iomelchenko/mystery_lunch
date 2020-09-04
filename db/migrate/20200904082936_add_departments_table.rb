# frozen_string_literal: true

class AddDepartmentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
