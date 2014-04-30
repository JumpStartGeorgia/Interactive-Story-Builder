class ChangeCaptionSizeOnMedia < ActiveRecord::Migration
  def change
  	change_column :media, :caption, :string, :limit => 2000
  end

end
