# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_17_134237) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "course_subjects", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "subject_id"], name: "index_course_subjects_on_course_id_and_subject_id", unique: true
    t.index ["course_id"], name: "index_course_subjects_on_course_id"
    t.index ["subject_id"], name: "index_course_subjects_on_subject_id"
  end

  create_table "courses", force: :cascade do |t|
    t.integer "academic_year", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "shift", default: 0, null: false
    t.bigint "study_plan_id", null: false
    t.datetime "updated_at", null: false
    t.integer "year_in_plan", null: false
    t.index ["study_plan_id", "name", "academic_year"], name: "idx_courses_unique", unique: true
    t.index ["study_plan_id"], name: "index_courses_on_study_plan_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "academic_year", null: false
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.bigint "school_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["discarded_at"], name: "index_enrollments_on_discarded_at"
    t.index ["school_id"], name: "index_enrollments_on_school_id"
    t.index ["user_id", "school_id", "academic_year"], name: "idx_enrollments_unique", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "grades", force: :cascade do |t|
    t.boolean "approved"
    t.string "conceptual_value"
    t.datetime "created_at", null: false
    t.bigint "entered_by_id"
    t.bigint "grading_instance_id", null: false
    t.text "notes"
    t.decimal "numeric_value", precision: 5, scale: 2
    t.bigint "subject_id", null: false
    t.bigint "transcript_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["grading_instance_id"], name: "idx_grades_instance"
    t.index ["grading_instance_id"], name: "index_grades_on_grading_instance_id"
    t.index ["subject_id"], name: "idx_grades_subject"
    t.index ["subject_id"], name: "index_grades_on_subject_id"
    t.index ["transcript_id", "subject_id", "grading_instance_id"], name: "idx_grades_unique", unique: true
    t.index ["transcript_id"], name: "index_grades_on_transcript_id"
    t.index ["user_id"], name: "idx_grades_user"
    t.index ["user_id"], name: "index_grades_on_user_id"
    t.check_constraint "numeric_value IS NOT NULL AND conceptual_value IS NULL OR numeric_value IS NULL AND conceptual_value IS NOT NULL OR numeric_value IS NULL AND conceptual_value IS NULL", name: "chk_grades_value_type"
  end

  create_table "grading_instances", force: :cascade do |t|
    t.integer "academic_year", null: false
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "entry_close_at"
    t.datetime "entry_open_at"
    t.integer "grade_type", default: 0, null: false
    t.boolean "is_final", default: false, null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.bigint "study_plan_id", null: false
    t.datetime "updated_at", null: false
    t.datetime "visible_from"
    t.datetime "visible_until"
    t.index ["study_plan_id", "academic_year"], name: "index_grading_instances_on_study_plan_id_and_academic_year"
    t.index ["study_plan_id"], name: "index_grading_instances_on_study_plan_id"
    t.check_constraint "entry_open_at IS NULL OR entry_close_at IS NULL OR entry_open_at < entry_close_at", name: "chk_grading_instances_entry_window"
  end

  create_table "schools", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "address"
    t.string "city"
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.decimal "max_grade", precision: 5, scale: 2, default: "10.0", null: false
    t.decimal "min_grade", precision: 5, scale: 2, default: "1.0", null: false
    t.string "name", null: false
    t.decimal "passing_grade", precision: 5, scale: 2, default: "6.0", null: false
    t.string "phone"
    t.string "postal_code"
    t.string "province"
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["discarded_at"], name: "index_schools_on_discarded_at"
    t.index ["subdomain"], name: "index_schools_on_subdomain", unique: true
    t.check_constraint "min_grade < passing_grade AND passing_grade <= max_grade", name: "chk_schools_grades"
  end

  create_table "study_plan_subjects", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.bigint "study_plan_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.integer "year_in_plan", null: false
    t.index ["study_plan_id", "subject_id", "year_in_plan"], name: "idx_study_plan_subjects_unique", unique: true
    t.index ["study_plan_id"], name: "index_study_plan_subjects_on_study_plan_id"
    t.index ["subject_id"], name: "index_study_plan_subjects_on_subject_id"
  end

  create_table "study_plans", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "duration_years", null: false
    t.integer "level", null: false
    t.string "name", null: false
    t.string "plan_type"
    t.bigint "school_id", null: false
    t.integer "start_year", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "name"], name: "index_study_plans_on_school_id_and_name", unique: true
    t.index ["school_id"], name: "index_study_plans_on_school_id"
  end

  create_table "subject_enrollments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "enrollment_id", null: false
    t.integer "status", default: 0, null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id", "subject_id"], name: "index_subject_enrollments_on_enrollment_id_and_subject_id", unique: true
    t.index ["enrollment_id"], name: "index_subject_enrollments_on_enrollment_id"
    t.index ["subject_id"], name: "index_subject_enrollments_on_subject_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "name"], name: "index_subjects_on_school_id_and_name", unique: true
    t.index ["school_id"], name: "index_subjects_on_school_id"
  end

  create_table "teacher_assignments", force: :cascade do |t|
    t.integer "academic_year", null: false
    t.boolean "active", default: true, null: false
    t.bigint "course_subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["course_subject_id", "user_id", "academic_year"], name: "idx_teacher_assignments_unique", unique: true
    t.index ["course_subject_id"], name: "index_teacher_assignments_on_course_subject_id"
    t.index ["user_id"], name: "idx_teacher_assignments_user"
    t.index ["user_id"], name: "index_teacher_assignments_on_user_id"
  end

  create_table "transcripts", force: :cascade do |t|
    t.integer "academic_year", null: false
    t.datetime "created_at", null: false
    t.bigint "enrollment_id", null: false
    t.boolean "locked", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id", "academic_year"], name: "index_transcripts_on_enrollment_id_and_academic_year", unique: true
    t.index ["enrollment_id"], name: "index_transcripts_on_enrollment_id"
  end

  create_table "user_role_schools", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "role", null: false
    t.bigint "school_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.date "valid_from", null: false
    t.date "valid_until"
    t.index ["school_id", "role"], name: "index_user_role_schools_on_school_id_and_role"
    t.index ["school_id"], name: "index_user_role_schools_on_school_id"
    t.index ["user_id", "school_id", "role"], name: "index_user_role_schools_on_user_id_and_school_id_and_role", unique: true
    t.index ["user_id"], name: "index_user_role_schools_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.date "birth_date"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "dni"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "surname", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["dni"], name: "index_users_on_dni"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "course_subjects", "courses"
  add_foreign_key "course_subjects", "subjects"
  add_foreign_key "courses", "study_plans"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "schools"
  add_foreign_key "enrollments", "users"
  add_foreign_key "grades", "grading_instances"
  add_foreign_key "grades", "subjects"
  add_foreign_key "grades", "transcripts"
  add_foreign_key "grades", "users"
  add_foreign_key "grades", "users", column: "entered_by_id"
  add_foreign_key "grading_instances", "study_plans"
  add_foreign_key "study_plan_subjects", "study_plans"
  add_foreign_key "study_plan_subjects", "subjects"
  add_foreign_key "study_plans", "schools"
  add_foreign_key "subject_enrollments", "enrollments"
  add_foreign_key "subject_enrollments", "subjects"
  add_foreign_key "subjects", "schools"
  add_foreign_key "teacher_assignments", "course_subjects"
  add_foreign_key "teacher_assignments", "users"
  add_foreign_key "transcripts", "enrollments"
  add_foreign_key "user_role_schools", "schools"
  add_foreign_key "user_role_schools", "users"
end
