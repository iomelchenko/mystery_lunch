# frozen_string_literal: true

class AddAllocationsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :allocations do |t|
      t.references :users, index: true, foreign_key: true
      t.references :meetings, index: true, foreign_key: true
    end
  end
end
