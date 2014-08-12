class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :from_user_id
      t.integer :story_id
      t.string :to_email
      t.integer :to_user_id
      t.string :key
      t.datetime :sent_at
      t.datetime :accepted_at

      t.timestamps
    end
    
    add_index :invitations, :key
    add_index :invitations, :story_id
    add_index :invitations, :to_user_id
  end
end
