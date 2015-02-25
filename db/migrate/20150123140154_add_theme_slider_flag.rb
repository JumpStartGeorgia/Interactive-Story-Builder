class AddThemeSliderFlag < ActiveRecord::Migration
  def change
    add_column :stories, :in_theme_slider, :boolean, :defualt => false
    add_index :stories, :in_theme_slider 
  end
end
