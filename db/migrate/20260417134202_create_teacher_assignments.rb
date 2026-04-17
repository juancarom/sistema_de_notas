class CreateTeacherAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :teacher_assignments do |t|
      t.references :course_subject, null: false, foreign_key: true
      t.references :user,           null: false, foreign_key: true
      t.integer :academic_year,     null: false
      t.boolean :active,            null: false, default: true

      t.timestamps
    end

    add_index :teacher_assignments, [:course_subject_id, :user_id, :academic_year],
              unique: true, name: "idx_teacher_assignments_unique"
    add_index :teacher_assignments, :user_id, name: "idx_teacher_assignments_user"
  end
end
