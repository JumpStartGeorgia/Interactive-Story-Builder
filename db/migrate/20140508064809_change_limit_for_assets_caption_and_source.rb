class ChangeLimitForAssetsCaptionAndSource < ActiveRecord::Migration
  def change
  	change_column :assets, :caption, :string, :limit => 2000
  	change_column :assets, :source, :string, :limit => 255
  end

end
