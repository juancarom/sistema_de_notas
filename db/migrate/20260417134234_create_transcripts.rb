class CreateTranscripts < ActiveRecord::Migration[8.1]
  def change
    create_table :transcripts do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.integer :academic_year, null: false
      t.boolean :locked,        null: false, default: false

      t.timestamps
    end

    add_index :transcripts, [:enrollment_id, :academic_year], unique: true
  end
end
