class Grade < ApplicationRecord
  belongs_to :transcript
  belongs_to :subject
  belongs_to :grading_instance
  belongs_to :user
  belongs_to :entered_by, class_name: "User", foreign_key: :entered_by_id, optional: true

  validates :transcript_id, uniqueness: { scope: [:subject_id, :grading_instance_id],
                                          message: "ya existe una nota para esta materia e instancia" }
  validate :value_type_matches_instance
  validate :transcript_not_locked

  after_commit :run_approval_check

  def value
    numeric_value || conceptual_value
  end

  private

  def value_type_matches_instance
    return unless grading_instance
    if grading_instance.numeric? && conceptual_value.present?
      errors.add(:conceptual_value, "no corresponde a una instancia numérica")
    elsif grading_instance.conceptual? && numeric_value.present?
      errors.add(:numeric_value, "no corresponde a una instancia conceptual")
    end
  end

  def transcript_not_locked
    errors.add(:base, "el analítico está cerrado y no acepta modificaciones") if transcript&.locked?
  end

  def run_approval_check
    GradeApprovalService.call(self)
  end
end
