class AddCommentCount < ActiveRecord::Migration
  def change
    add_column :stories, :comments_count, :integer, :default => 0
    add_index :stories, :comments_count
  end
end
