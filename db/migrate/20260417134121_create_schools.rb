class CreateSchools < ActiveRecord::Migration[8.1]
  def change
    create_table :schools do |t|
      t.string  :name,          null: false
      t.string  :subdomain,     null: false
      t.decimal :min_grade,     null: false, default: "1.0",  precision: 5, scale: 2
      t.decimal :max_grade,     null: false, default: "10.0", precision: 5, scale: 2
      t.decimal :passing_grade, null: false, default: "6.0",  precision: 5, scale: 2
      t.string  :address
      t.string  :city
      t.string  :province
      t.string  :postal_code
      t.string  :phone
      t.string  :contact_email
      t.string  :website
      t.boolean :active,        null: false, default: true
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :schools, :subdomain, unique: true
    add_index :schools, :discarded_at

    add_check_constraint :schools,
      "min_grade < passing_grade AND passing_grade <= max_grade",
      name: "chk_schools_grades"
  end
end
