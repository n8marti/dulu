class Workshop < ApplicationRecord
  belongs_to :linguistic_activity, required: true
  belongs_to :event, required: false, dependent: :destroy
  belongs_to :stage, required: false, dependent: :destroy

  validates :number, numericality: {only_integer: true}
  validates :name, presence: true, allow_blank: false

  default_scope { order :number }

  # def stage
  #   linguistic_activity.stages.find_by(name: name)
  # end

  def f_date
    if event
      event.f_end_date
    elsif stage
      stage.f_start_date
    else
      nil
    end
  end

  def set_event_defaults(event)
    event.assign_attributes(
         name: "#{I18n.t(:Workshop)}: #{name}",
         domain: :Linguistics
    )
  end

  def completed?
    !stage.nil?
  end
  alias complete? completed?

  def complete(params)
    date = (event.nil?) ?
               params[:date] :
               event.end_date
    stage = linguistic_activity.stages.create!(
        kind: :Linguistic,
        name: name,
        start_date: date
    )
    update(stage: stage)
  end

  def to_hash
    {
        id: id,
        complete: !stage.nil?,
        completed_text: I18n.t(:Completed),
        date: f_date.try(:pretty_print),
        activity: linguistic_activity.to_hash
    }
  end
end