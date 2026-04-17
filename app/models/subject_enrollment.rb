class SubjectEnrollment < ApplicationRecord
  belongs_to :enrollment
  belongs_to :subject

  enum :status, { enrolled: 0, passed: 1, failed: 2, withdrawn: 3 }

  validates :subject_id, uniqueness: { scope: :enrollment_id }
end
