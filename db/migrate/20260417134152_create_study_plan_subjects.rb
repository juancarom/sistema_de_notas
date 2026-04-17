class CreateStudyPlanSubjects < ActiveRecord::Migration[8.1]
  def change
    create_table :study_plan_subjects do |t|
      t.references :study_plan, null: false, foreign_key: true
      t.references :subject,    null: false, foreign_key: true
      t.integer :year_in_plan,  null: false
      t.boolean :active,        null: false, default: true

      t.timestamps
    end

    add_index :study_plan_subjects, [:study_plan_id, :subject_id, :year_in_plan], unique: true,
              name: "idx_study_plan_subjects_unique"
  end
end
