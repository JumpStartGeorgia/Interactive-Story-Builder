class AddProcessedToNotificationTriggers < ActiveRecord::Migration
  def change
   add_column :notification_triggers, :processed, :boolean, {:default=>false}
  end
end
