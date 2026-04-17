class TeacherAssignment < ApplicationRecord
  belongs_to :course_subject
  belongs_to :user

  has_one :course,  through: :course_subject
  has_one :subject, through: :course_subject

  validates :academic_year, presence: true, numericality: { only_integer: true }
  validates :user_id, uniqueness: { scope: [:course_subject_id, :academic_year],
                                    message: "ya está asignado a esta materia este año" }
  validate :user_must_be_teacher

  private

  def user_must_be_teacher
    school = course_subject&.course&.study_plan&.school
    return unless school && user
    unless user.has_role_at?(:teacher, school)
      errors.add(:user, "debe tener rol de docente en la institución")
    end
  end
end
