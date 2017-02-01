class ChangeCaptionLimit < ActiveRecord::Migration
  def change
    change_column :medium_translations, :caption, :string, :limit => 500
    change_column :slideshow_translations, :caption, :string, :limit => 500
  end
end
