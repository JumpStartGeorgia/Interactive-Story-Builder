class ChangeCaptionLimit < ActiveRecord::Migration
  def up
    change_column :medium_translations, :caption, :string, :limit => 500
    change_column :slideshow_translations, :caption, :string, :limit => 500
    change_column :infographic_translations, :caption, :string, :limit => 500
    change_column :content_translations, :caption, :string, :limit => 500
    change_column :content_translations, :sub_caption, :string, :limit => 500
  end

  def down
    change_column :medium_translations, :caption, :string, :limit => 255
    change_column :slideshow_translations, :caption, :string, :limit => 255
    change_column :infographic_translations, :caption, :string, :limit => 255
    change_column :content_translations, :caption, :string, :limit => 255
    change_column :content_translations, :sub_caption, :string, :limit => 255
  end
end
