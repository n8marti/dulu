class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update]

  def index
    @people = Person.all.includes(:organization)
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @person.to_hash }
    end
  end

  # noinspection RubyArgCount
  def new
    authorize! :create, Person
    @person = Person.new
  end

  def edit
    authorize! :update, @person
  end

  def create
    authorize! :create, Person
    @person = Person.new(person_params)
    if @person.save
      follow_redirect people_path, person_id: @person.id
    else
      render 'new'
    end
  end

  def update
    authorize! :update, @person
    if @person.update(person_params)
      follow_redirect people_path
    else
      render 'edit'
    end
  end

  def not_allowed

  end

  def find
    @match = Person.find_by("first_name ILIKE ? AND last_name ILIKE ?", params[:first], params[:last])
    response = @match.nil? ? {match: false} : {match: true, name: @match.full_name, email: @match.email}
    render json: response
  end

private
  def person_params
    permitted = %i( first_name last_name email birth_date organization_id gender country_id ui_language )
    permitted << :has_login if can? :grant_login, Person
    params.require(:person).permit(permitted)
  end

  def set_person
    @person = Person.find params[:id]
  end

  def logged_in_user
    unless logged_in?
      redirect_to login_url
    end
  end
end
