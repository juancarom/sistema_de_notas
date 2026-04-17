class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.bigint  :course_id
      t.integer :academic_year, null: false
      t.integer :status,        null: false, default: 0
      t.datetime :discarded_at

      t.timestamps
    end

    add_foreign_key :enrollments, :courses, column: :course_id
    add_index :enrollments, [:user_id, :school_id, :academic_year], unique: true,
              name: "idx_enrollments_unique"
    add_index :enrollments, :course_id
    add_index :enrollments, :discarded_at
  end
end
