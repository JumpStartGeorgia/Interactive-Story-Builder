class AddIndexToNotifications < ActiveRecord::Migration
  def change   
   add_index :notifications, [:notification_type,:identifier], :name => "idx_notif_type"
   add_index :notifications, :user_id, :name => "index_notifications_on_user_id"
  end
end
