class EventsController < ApplicationController

  def index
    if params[:program_id]
      @program = Program.find(params[:program_id])
      render 'index_for_program'
    else
      render 'index'
    end
  end

  def new
    authorize! :create, Event
    if params[:program_id]
      @program = Program.find params[:program_id]
      @event = @program.events.build
      render 'new_for_program'
    else
      @event = Event.new
      render 'new'
    end
  end

  def create
    authorize! :create, Event
    @event = Event.new(prepared_event_params)
    if(@event.save)
      redirect_to params[:program_id] ? dashboard_program_path(params[:program_id]) :
                                        events_path
    else
      render 'new'
    end
  end

  def edit
    @event = Event.find params[:id]
    authorize! :update, @event
  end

  def update
    @event = Event.find params[:id]
    authorize! :update, @event
    if(@event.update(prepared_event_params))
      follow_redirect events_path
    else
      render 'edit'
    end
  end

  def destroy
    @event = Event.find params[:id]
    authorize! :destroy, @event
    @event.destroy
    follow_redirect events_path
  end

  private

  def prepared_event_params
    prms = event_params
    prms[:event_participants] = []
    prms[:program_ids] ||= []
    prms[:program_ids].uniq!
    prms[:new_event_participants].each do |ep_params|
      unless ep_params[:person_id].blank?
        prms[:event_participants] << EventParticipant.new(ep_params)
      end
    end
    prms[:event_participant].try(:each) do |ep_id, ep_params|
      ep = EventParticipant.find_by(id: ep_id) || EventParticipant.new
      ep.assign_attributes(ep_params)
      prms[:event_participants] << ep
    end
    prms.delete(:event_participant)
    prms.delete(:new_event_participants)
    prms
  end

  def event_params
    assemble_dates params, 'event', 'start_date', 'end_date'
    params.require(:event).permit(:domain, :name, :start_date, :end_date, :note,
                                  program_ids: [],
                                  event_participant: [:person_id, :program_role_id],
                                  new_event_participants: [:person_id, :program_role_id])
  end
end
