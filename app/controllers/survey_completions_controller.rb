class SurveyCompletionsController < ApplicationController

  before_action :set_program_and_survey
  before_action :authorize

  def new
  end

  def create
    SurveyCompletion.create(survey: @survey, program: @program, person: current_user)
    redirect_to dashboard_program_path(@program)
  end

  def destroy
    SurveyCompletion.find_by(survey: @survey, program: @program).try(:destroy)
    render :new
  end

  private

  def set_program_and_survey
    @program = Program.find params[:program_id]
    @survey = Survey.find params[:survey_id]
  end

  def authorize
    authorize! :manage_surveys, @program
  end
end