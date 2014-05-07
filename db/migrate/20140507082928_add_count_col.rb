class AddCountCol < ActiveRecord::Migration
  def up
    add_column :stories, :impressions_count, :integer, :default => 0
  end

  def down
    remove_column :stories, :impressions_count
  end
end
