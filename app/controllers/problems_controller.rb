# -*- coding: utf-8 -*-
class ProblemsController < ApplicationController

  before_filter :require_login, only: [:new, :create, :answer, :edit, :update]

  # GET /problems
  # GET /problems.json
  def index
    @problems = Problem.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @problems }
    end
  end

  # GET /problems/1
  # GET /problems/1.json
  def show
    @problem = Problem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @problem }
    end
  end

  # POST /problems/answer/1
  # POST /problems/answer/1.json
  def answer
    @problem = Problem.find(params[:id])

    @problem.answer_by(current_user, params[:choice])

    respond_to do |format|
      format.html { redirect_to @problem }
      format.json { render json: @problem, status: :answered, location: @problem }
    end
  end

  # GET /problems/new
  # GET /problems/new.json
  def new
    @problem = Problem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @problem }
    end
  end

  # POST /problems
  # POST /problems.json
  def create
    correct = params[:problem][:correct]
    params[:problem].delete(:correct)
    @problem = Problem.new(params[:problem]) do |prob|
      prob.correct = correct
    end
    @problem.creator = current_user

    respond_to do |format|
      if @problem.save
        format.html { redirect_to @problem, notice: t('helpers.action.create_problem') }
        format.json { render json: @problem, status: :created, location: @problem }
      else
        format.html { render action: "new" }
        format.json { render json: @problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /problems/1/edit
  def edit
    @problem = Problem.find(params[:id])
    render :status => :forbidden, :text => "他人の作成した問題を編集することはできません" unless @problem.creator == current_user
  end

  # PUT /problems/1
  # PUT /problems/1.json
  def update
    @problem = Problem.find(params[:id])

    if @problem.creator == current_user
      respond_to do |format|
        params[:problem].delete(:correct)
        if @problem.update_attributes(params[:problem])
          format.html { redirect_to @problem, notice: t('helpers.action.create_problem') }
          format.json { render json: @problem, status: :created, location: @problem }
        else
          format.html { render action: "new" }
          format.json { render json: @problem.errors, status: :unprocessable_entity }
        end
      end
    else
      render :status => :forbidden, :text => "他人の作成した問題を編集することはできません"
    end
  end

  private
  def require_login
    redirect_to '/', notice: t('helpers.action.not_logged_in') unless current_user
  end
end
