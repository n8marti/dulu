class EventsController < ApplicationController
  include EventsHelper

  def index
    if params[:program_id]
      @program = Program.find(params[:program_id])
      render 'index_for_program'
    else
      render 'index'
    end
  end

  def past
    @program = Program.find(params[:program_id]) if params[:program_id]
    @events = @program ? @program.events.past : Event.past
    @events = @events.page(params[:page])
  end

  def new
    authorize! :create, Event

    if params[:program_id]
      @program = Program.find params[:program_id]
      @event = @program.events.build
    else
      @event = Event.new
    end

    if params[:workshop]
      @workshop = Workshop.find(params[:workshop])
      @workshop.set_event_defaults(@event)
      authorize! :update, @workshop.linguistic_activity
    end
  end

  def create
    authorize! :create, Event
    @event = Event.new(event_params)
    @program = Program.find(params[:program_id]) if params[:program_id]
    workshop = Workshop.find_by id: params[:workshop_id]
    if @event.save
      @event.programs << @program if @program
      if workshop
        @event.workshop = workshop
        follow_redirect activity_path(workshop.linguistic_activity)
      else
        redirect_to ctxt_event_path(@program, @event)
        new_event_for_program_notification if @program
      end
    else
      render 'new'
    end
  end

  def show
    @event = Event.find params[:id]
    @program = Program.find params[:program_id] if params[:program_id]
  end

  def edit
    @event = Event.find params[:id]
    authorize! :update, @event
    @program = Program.find(params[:program_id]) if params[:program_id]
  end

  def update
    @event = Event.find params[:id]
    authorize! :update, @event
    if @event.update(event_params)
      follow_redirect events_path
    else
      render 'edit'
    end
  end

  def add_update
    @event = Event.find params[:id]
    authorize! :update, @event
    add_cluster_and_notify if params[:event_cluster]
    add_program_and_notify if params[:event_program]
    add_participant_and_notify if params[:event_person]
    redirect_to ctxt_event_path(params[:program_id], @event)
  end

  def remove_update
    @event = Event.find params[:id]
    authorize! :update, @event
    @event.clusters.delete(params[:cluster_id]) if params[:cluster_id]
    @event.programs.delete(params[:remove_program]) if params[:remove_program]
    EventParticipant.find(params[:remove_participant]).delete if params[:remove_participant]
    redirect_to ctxt_event_path(params[:program_id], @event)
  end

  def destroy
    @event = Event.find params[:id]
    authorize! :destroy, @event
    @event.destroy
    redirect_to ctxt_events_path(params[:program_id])
  end

  private

  def event_params
    assemble_dates params, 'event', 'start_date', 'end_date'
    params[:event][:creator_id] = current_user.id
    params.require(:event).permit(:domain, :name, :start_date, :end_date, :note, :creator_id)
  end

  def new_event_for_program_notification
    Notification.new_event_for_program current_user, @event, @program
  end

  def add_cluster_and_notify
    cluster = Cluster.find params[:event_cluster]
    @event.clusters << cluster
    Notification.added_cluster_to_event current_user, cluster, @event
  end

  def add_program_and_notify
    program = Program.find params[:event_program]
    @event.programs << program
    Notification.added_program_to_event current_user, program, @event
  end

  def add_participant_and_notify
    event_participant = EventParticipant.build @event, params[:event_person]
    Notification.added_you_to_event current_user, event_participant
  end
end
