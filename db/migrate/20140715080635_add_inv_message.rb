class AddInvMessage < ActiveRecord::Migration
  def change
    add_column :invitations, :message, :text
  end
end
