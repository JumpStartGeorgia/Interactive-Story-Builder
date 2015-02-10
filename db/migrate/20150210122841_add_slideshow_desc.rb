class AddSlideshowDesc < ActiveRecord::Migration
  def change
    add_column :slideshow_translations, :description, :text
  end
end
