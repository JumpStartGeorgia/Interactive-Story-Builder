class AddUserEmailClone < ActiveRecord::Migration
  def up
    add_column :users, :email_no_domain, :string
    add_index :users, :email_no_domain
    add_index :users, :nickname
    
    # populate the new column
    User.transaction do 
      User.all.each do |user|
        user.create_email_no_domain      
        user.save
      end
    end
  end

  def down
    remove_index :users, :email_no_domain
    remove_column :users, :email_no_domain, :string
    remove_index :users, :nickname
  end
end
