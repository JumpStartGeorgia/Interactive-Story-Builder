class UpdateUsers < ActiveRecord::Migration
  def up
      add_index :users, [:notification_language, :wants_notifications] , name:"index_users_on_notif_lang_and_wants_notif"
      change_column :users, :notification_language, :string, { :default=>'en'}

      User.where(:notification_language => nil).update_all(:notification_language => 'en')   
  end  
  def down
   remove_index :users, [:notification_language, :wants_notifications] 
   change_column :users, :notification_language, :string

  end
end