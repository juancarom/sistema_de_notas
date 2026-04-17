class EnrollmentService
  attr_reader :user, :school, :academic_year, :errors

  def initialize(user:, school:, academic_year:)
    @user = user
    @school = school
    @academic_year = academic_year
    @errors = []
  end

  def enroll_in_course(course)
    ActiveRecord::Base.transaction do
      enrollment = Enrollment.create!(
        user: user, school: school, course: course,
        academic_year: academic_year, status: :active
      )
      Transcript.create!(enrollment: enrollment, academic_year: academic_year)
      enrollment
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors << e.message
    nil
  end

  def transfer_to_course(enrollment, new_course)
    enrollment.update!(course: new_course)
  rescue ActiveRecord::RecordInvalid => e
    @errors << e.message
    nil
  end

  def self.bulk_transfer(enrollment_ids, new_course, school)
    Enrollment.where(id: enrollment_ids, school: school)
              .update_all(course_id: new_course.id)
  end

  def enroll_in_subject(subject)
    ActiveRecord::Base.transaction do
      enrollment = Enrollment.find_or_create_by!(
        user: user, school: school, academic_year: academic_year
      ) { |e| e.status = :active }

      Transcript.find_or_create_by!(enrollment: enrollment, academic_year: academic_year)

      SubjectEnrollment.find_or_create_by!(
        enrollment: enrollment, subject: subject
      ) { |se| se.status = :enrolled }
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors << e.message
    nil
  end
end
