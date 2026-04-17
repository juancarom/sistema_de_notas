class CreateGrades < ActiveRecord::Migration[8.1]
  def change
    create_table :grades do |t|
      t.references :transcript,       null: false, foreign_key: true
      t.references :subject,          null: false, foreign_key: true
      t.references :grading_instance, null: false, foreign_key: true
      t.references :user,             null: false, foreign_key: true
      t.bigint  :entered_by_id
      t.decimal :numeric_value,   precision: 5, scale: 2
      t.string  :conceptual_value
      t.boolean :approved
      t.text    :notes

      t.timestamps
    end

    add_foreign_key :grades, :users, column: :entered_by_id
    add_index :grades, [:transcript_id, :subject_id, :grading_instance_id],
              unique: true, name: "idx_grades_unique"
    add_index :grades, :user_id,             name: "idx_grades_user"
    add_index :grades, :subject_id,          name: "idx_grades_subject"
    add_index :grades, :grading_instance_id, name: "idx_grades_instance"

    add_check_constraint :grades,
      "(numeric_value IS NOT NULL AND conceptual_value IS NULL) OR " \
      "(numeric_value IS NULL AND conceptual_value IS NOT NULL) OR " \
      "(numeric_value IS NULL AND conceptual_value IS NULL)",
      name: "chk_grades_value_type"
  end
end
