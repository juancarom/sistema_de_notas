class Course < ApplicationRecord
  belongs_to :study_plan
  has_many :course_subjects, dependent: :destroy
  has_many :subjects, through: :course_subjects
  has_many :teacher_assignments, through: :course_subjects
  has_many :enrollments, dependent: :restrict_with_error

  delegate :school, to: :study_plan

  enum :shift, { single: 0, morning: 1, afternoon: 2, evening: 3 }

  validates :name,          presence: true
  validates :year_in_plan,  presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :academic_year, presence: true, numericality: { only_integer: true }
  validates :name, uniqueness: { scope: [:study_plan_id, :academic_year] }

  SHIFT_LABELS = { "single" => "Único", "morning" => "Mañana", "afternoon" => "Tarde", "evening" => "Noche" }.freeze

  def shift_label
    SHIFT_LABELS[shift]
  end
end
