class CourseSubject < ApplicationRecord
  belongs_to :course
  belongs_to :subject
  has_many :teacher_assignments, dependent: :destroy

  validates :subject_id, uniqueness: { scope: :course_id }
end
