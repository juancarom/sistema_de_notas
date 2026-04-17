class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.references :study_plan,   null: false, foreign_key: true
      t.string  :name,            null: false
      t.integer :year_in_plan,    null: false
      t.integer :shift,           null: false, default: 0
      t.integer :academic_year,   null: false
      t.boolean :active,          null: false, default: true

      t.timestamps
    end

    add_index :courses, [:study_plan_id, :name, :academic_year], unique: true,
              name: "idx_courses_unique"
  end
end
