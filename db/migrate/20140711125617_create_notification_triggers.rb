class CreateNotificationTriggers < ActiveRecord::Migration
  def change
    create_table :notification_triggers do |t|
      t.integer :notification_type
      t.integer :identifier

      t.timestamps
    end
  end
end
