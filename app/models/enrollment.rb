class Enrollment < ApplicationRecord
  acts_as_tenant :school

  belongs_to :user
  belongs_to :school
  belongs_to :course, optional: true

  has_many :subject_enrollments, dependent: :destroy
  has_many :subjects, through: :subject_enrollments
  has_one  :transcript, dependent: :destroy

  include Discard::Model

  enum :status, { active: 0, graduated: 1, withdrawn: 2 }

  validates :academic_year, presence: true, numericality: { only_integer: true }
  validates :user_id, uniqueness: { scope: [:school_id, :academic_year],
                                    message: "ya tiene matrícula en esta institución para este año" }

  def subjects_for_transcript
    if course
      course.subjects
    else
      subjects
    end
  end
end
