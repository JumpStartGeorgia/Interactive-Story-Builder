class RenameSubtitleToSubCaption < ActiveRecord::Migration
  def up
  	 rename_column :contents, :subtitle, :sub_caption
  end

  def down
  	 rename_column :contents, :sub_caption, :subtitle
  end
end
