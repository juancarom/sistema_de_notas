class Teachers::GradesController < Teachers::BaseController
  def create
    @grade = Grade.find_or_initialize_by(grade_lookup_params)
    @grade.assign_attributes(grade_value_params.merge(entered_by: current_user))
    authorize @grade
    if @grade.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("grade_cell_#{cell_id}", partial: "teachers/grades/cell", locals: { grade: @grade }) }
        format.html { redirect_back fallback_location: root_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("grade_cell_#{cell_id}", partial: "teachers/grades/cell_error", locals: { grade: @grade }) }
        format.html { redirect_back fallback_location: root_path, alert: @grade.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @grade = Grade.find(params[:id])
    authorize @grade
    @grade.assign_attributes(grade_value_params.merge(entered_by: current_user))
    if @grade.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("grade_cell_#{cell_id}", partial: "teachers/grades/cell", locals: { grade: @grade }) }
        format.html { redirect_back fallback_location: root_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("grade_cell_#{cell_id}", partial: "teachers/grades/cell_error", locals: { grade: @grade }) }
        format.html { redirect_back fallback_location: root_path, alert: @grade.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def grade_lookup_params
    p = params.require(:grade).permit(:transcript_id, :subject_id, :grading_instance_id, :user_id)
    p.merge(user_id: p[:user_id] || Transcript.find(p[:transcript_id]).enrollment.user_id)
  end

  def grade_value_params
    params.require(:grade).permit(:numeric_value, :conceptual_value, :notes)
  end

  def cell_id
    p = params.require(:grade).permit(:transcript_id, :subject_id, :grading_instance_id)
    "#{p[:transcript_id]}_#{p[:subject_id]}_#{p[:grading_instance_id]}"
  end
end
