# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create test_create destroy]

  def new
    if logged_in?
      redirect_to root_path
    else
      redirect_to '/auth/google_oauth2'
    end
  end

  def create
    @gmail = request.env['omniauth.auth']['info']['email']
    person = Person.where('email ILIKE ?', @gmail).first
    if person.try :has_login
      reset_user_session
      log_in person
      send_to_correct_page
    else
      session[:failed_login] = @gmail
      redirect_to root_path
    end
  end

  def test_create
    user = params[:id] ? Person.find(params[:id]) : Person.find_by(email: params[:email])
    log_in user
    response_ok
  end

  def destroy
    log_out
    redirect_to root_path
  end

  def login_as
    new_user = Person.find params[:id]
    authorize! :login_as_others, new_user
    log_in new_user
    redirect_to root_path
  end

  private

  def send_to_correct_page
    if session[:original_request]
      redirect_to session[:original_request]
      session.delete(:original_request)
    else
      redirect_to root_path
    end
  end

  def reset_user_session
    old = session.to_hash
    reset_session
    session.merge! old
  end
end
