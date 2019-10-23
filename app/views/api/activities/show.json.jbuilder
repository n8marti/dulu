
json.activity do
  json.call(@activity,
            :id,
            :bible_book_id,
            :name,
            :type,
            :note,
            :category,
            :title,
            :scripture,
            :film,
            :participant_ids,
            :stage_name,
            :language_id)
  json.stage_date @activity.current_stage.start_date

  json.stages @activity.stages.order(start_date: :desc) do |stage|
    json.call(stage, :id, :name, :start_date, :activity_id)
  end

  json.can do
    json.update can?(:update, @activity)
  end

  if @activity.category == :Workshops
    json.workshops Workshop.sort(@activity.workshops), partial: "api/workshops/workshop", as: :workshop
  end
end

json.language do
  json.call(@activity.language, :id, :name)
end

json.participants @activity.participants do |participant|
  json.call(participant, :id, :person_id, :language_id, :cluster_id, :roles)
end

json.people @activity.people do |person|
  json.call(person, :id, :first_name, :last_name)
end
