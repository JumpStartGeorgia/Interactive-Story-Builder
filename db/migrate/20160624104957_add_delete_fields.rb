class AddDeleteFields < ActiveRecord::Migration
  def change
    add_column :stories, :deleted, :boolean, default: false
    add_column :stories, :deleted_at, :datetime
    add_index :stories, :deleted
  end
end
