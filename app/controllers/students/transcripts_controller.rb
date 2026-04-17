class Students::TranscriptsController < Students::BaseController
  def index
    if current_user_has_role?(:student)
      @transcripts = policy_scope(Transcript)
                       .joins(:enrollment)
                       .where(enrollments: { user: current_user, school: current_school })
                       .order(academic_year: :desc)
    else
      student = User.find_by(id: params[:user_id])
      if student
        @transcripts = Transcript.joins(:enrollment)
                                  .where(enrollments: { user: student, school: current_school })
                                  .order(academic_year: :desc)
        authorize @transcripts.first || Transcript.new
      else
        @transcripts = policy_scope(Transcript)
                         .joins(enrollment: :user)
                         .where(enrollments: { school: current_school })
                         .order("transcripts.academic_year DESC, users.surname")
                         .includes(enrollment: :user)
      end
    end
  end

  def show
    @transcript = Transcript.joins(:enrollment)
                             .where(enrollments: { school: current_school })
                             .find(params[:id])
    authorize @transcript
    @enrollment = @transcript.enrollment
    @student    = @enrollment.user
    @subjects   = @enrollment.subjects_for_transcript.order(:name)
    @grading_instances = GradingInstance.joins(:study_plan)
                                         .where(study_plans: { school: current_school })
                                         .where(study_plan: @enrollment.course&.study_plan,
                                                academic_year: @transcript.academic_year)
                                         .order(:position)
    @grades_map = @transcript.grades
                              .index_by { |g| [g.subject_id, g.grading_instance_id] }
  end
end
