class SessionsController < ApplicationController
  
  skip_before_action :require_login, only: [:new, :create]

  def new
    if logged_in?
      redirect_to root_path
    end
  end

  def create
    @gmail = request.env['omniauth.auth']['info']['email']
    person = Person.find_by(email: @gmail)
    if person.try :has_login
      log_in person
      send_to_correct_page
    else
      render 'no_account'
    end
  end

  def send_to_correct_page
    if session[:original_request]
      redirect_to session[:original_request]
      session.delete(:original_request)
    else
      redirect_to root_path
    end
  end

  def destroy
    log_out
    redirect_to login_path
  end

  def gcreate

  end
end
