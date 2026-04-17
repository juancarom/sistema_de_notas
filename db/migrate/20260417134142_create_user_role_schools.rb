class CreateUserRoleSchools < ActiveRecord::Migration[8.1]
  def change
    create_table :user_role_schools do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.integer :role,       null: false
      t.date    :valid_from, null: false
      t.date    :valid_until
      t.boolean :active,     null: false, default: true

      t.timestamps
    end

    add_index :user_role_schools, [:user_id, :school_id, :role], unique: true
    add_index :user_role_schools, [:school_id, :role]
  end
end
