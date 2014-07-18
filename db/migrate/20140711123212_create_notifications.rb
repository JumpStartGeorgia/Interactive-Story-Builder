class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :notification_type
      t.integer :identifier

      t.timestamps
    end
  end
end
