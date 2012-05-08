class ProblemsController < ApplicationController
  respond_to :html

  before_filter :require_login, only: [:new, :create, :answer, :edit, :update]

  def index
    @problems = Problem.paginate(:page => params[:page])
  end

  def show
    @problem = Problem.find(params[:id])
  end

  # POST /problems/answer/1
  def answer
    @problem = Problem.find(params[:id])

    @problem.answer_by(current_user, params[:choice])

    redirect_to @problem
  end

  def new
    @problem = Problem.new
  end

  def create
    correct = params[:problem][:correct]
    params[:problem].delete(:correct)
    @problem = Problem.new(params[:problem]) do |prob|
      prob.correct = correct
    end
    @problem.creator = current_user

    @problem.save
    respond_with @problem, location: @problem, notice: t('helpers.action.create_problem')
  end

  def edit
    @problem = Problem.find(params[:id])
    render_not_owner_error unless @problem.creator == current_user
  end

  def update
    @problem = Problem.find(params[:id])

    if @problem.creator == current_user
      params[:problem].delete(:correct)
      @problem.update_attributes(params[:problem])
      respond_with @problem, location: problem_path(@problem), notice: t('helpers.action.update_problem')
    else
      render_not_owner_error
    end
  end

  private
  def require_login
    redirect_to '/', notice: t('helpers.action.not_logged_in') unless current_user
  end

  def render_not_owner_error
    render :status => :forbidden, :text => t('helpers.action.not_editable')
  end
end
