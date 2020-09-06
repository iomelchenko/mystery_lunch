# frozen_string_literal: true

class AddEmailPasswordRoleToUser < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :email, :string, null: false
    add_column :users, :password_digest, :string, null: false
    add_column :users, :role, :integer, null: false, default: 0

    change_column :users, :state, :integer, null: false, default: 0
  end

  def down
    remove_column :users, :email
    remove_column :users, :password_digest
    remove_column :users, :role

    change_column :users, :state, :integer, null: false
  end
end
