class Admin::SubjectsController < Admin::BaseController
  before_action :set_subject, only: [:edit, :update, :destroy]

  def index
    @subjects = policy_scope(Subject).order(:name)
  end

  def new
    authorize Subject
    @subject = Subject.new
  end

  def create
    authorize Subject
    @subject = Subject.new(subject_params)
    if @subject.save
      redirect_to admin_subjects_path, notice: "Materia creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @subject
  end

  def update
    authorize @subject
    if @subject.update(subject_params)
      redirect_to admin_subjects_path, notice: "Materia actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @subject
    @subject.destroy
    redirect_to admin_subjects_path, notice: "Materia eliminada."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_subjects_path, alert: "No se puede eliminar: tiene notas cargadas."
  end

  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :code, :active)
  end
end
