class StudyPlanSubject < ApplicationRecord
  belongs_to :study_plan
  belongs_to :subject

  validates :year_in_plan, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :subject_id, uniqueness: { scope: [:study_plan_id, :year_in_plan],
                                       message: "ya está en este año del plan" }
end
