class AddWantsNotificationsAndNotificationLanguageToUsers < ActiveRecord::Migration
  def change
  	 	add_column :users, :wants_notifications, :boolean, { default: true }        
  	 	add_column :users, :notification_language, :string
  end
end
