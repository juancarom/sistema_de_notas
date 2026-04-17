class StudyPlan < ApplicationRecord
  acts_as_tenant :school

  belongs_to :school
  has_many :study_plan_subjects, dependent: :destroy
  has_many :subjects, through: :study_plan_subjects
  has_many :courses, dependent: :destroy
  has_many :grading_instances, dependent: :destroy

  enum :level, { preschool: 0, primary: 1, secondary: 2, tertiary: 3 }

  validates :name,           presence: true
  validates :level,          presence: true
  validates :duration_years, presence: true, numericality: { greater_than: 0 }
  validates :start_year,     presence: true, numericality: { only_integer: true }
  validates :name, uniqueness: { scope: :school_id }

  LEVEL_LABELS = {
    "preschool" => "Nivel Inicial",
    "primary"   => "Primaria",
    "secondary" => "Secundaria",
    "tertiary"  => "Terciario / Superior"
  }.freeze

  def level_label
    LEVEL_LABELS[level]
  end
end
