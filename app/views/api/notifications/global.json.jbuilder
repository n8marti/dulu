# frozen_string_literal: true

json.notifications @notifications do |notification|
  json.call(notification, :id, :text, :created_at)
end

json.moreAvailable @more_available
json.unreadNotifications false
