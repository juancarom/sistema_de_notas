class CreateGradingInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :grading_instances do |t|
      t.references :study_plan,   null: false, foreign_key: true
      t.string  :name,            null: false
      t.integer :position,        null: false, default: 0
      t.integer :grade_type,      null: false, default: 0
      t.boolean :enabled,         null: false, default: false
      t.boolean :is_final,        null: false, default: false
      t.integer :academic_year,   null: false
      t.datetime :visible_from
      t.datetime :visible_until
      t.datetime :entry_open_at
      t.datetime :entry_close_at

      t.timestamps
    end

    add_index :grading_instances, [:study_plan_id, :academic_year]

    add_check_constraint :grading_instances,
      "entry_open_at IS NULL OR entry_close_at IS NULL OR entry_open_at < entry_close_at",
      name: "chk_grading_instances_entry_window"
  end
end
