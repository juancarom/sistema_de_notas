class Subject < ApplicationRecord
  acts_as_tenant :school

  belongs_to :school
  has_many :study_plan_subjects, dependent: :destroy
  has_many :study_plans, through: :study_plan_subjects
  has_many :course_subjects, dependent: :destroy
  has_many :courses, through: :course_subjects
  has_many :subject_enrollments, dependent: :destroy
  has_many :grades, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: { scope: :school_id }
end
