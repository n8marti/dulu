class AddCreatorIdToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :creator_id, :integer
  end
end
