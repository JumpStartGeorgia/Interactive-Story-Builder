class AddIndexToNotificationTriggers < ActiveRecord::Migration
  def change
     add_index :notification_triggers, :notification_type, { name:"index_notification_triggers_on_notification_type"}
  end
end
