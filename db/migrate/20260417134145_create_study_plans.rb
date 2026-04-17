class CreateStudyPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :study_plans do |t|
      t.references :school,         null: false, foreign_key: true
      t.string  :name,              null: false
      t.integer :level,             null: false
      t.integer :duration_years,    null: false
      t.string  :plan_type
      t.integer :start_year,        null: false
      t.boolean :active,            null: false, default: true

      t.timestamps
    end

    add_index :study_plans, [:school_id, :name], unique: true
  end
end
