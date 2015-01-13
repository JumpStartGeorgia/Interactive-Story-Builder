class ChangeLimitForMedia < ActiveRecord::Migration
  def up
  	change_column :media, :caption, :string, :limit => 180
  end

  def down
  	 change_column :media, :caption, :string, :limit => 2000
  end
end
