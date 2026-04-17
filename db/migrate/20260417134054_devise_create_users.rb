# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Personal info
      t.string :name,       null: false, default: ""
      t.string :surname,    null: false, default: ""
      t.string :dni
      t.date   :birth_date
      t.string :phone
      t.string :address
      t.string :city

      ## Soft delete
      t.datetime :discarded_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :dni
    add_index :users, :discarded_at
  end
end
