class AddIframeStuffToInfographicAndRemoveFromInfographicTranslation < ActiveRecord::Migration
  def change
    add_column :infographics, :dynamic_width, :integer, :default => 0
    add_column :infographics, :dynamic_height, :integer, :default => 0
    remove_column :infographic_translations, :dynamic_width
    remove_column :infographic_translations, :dynamic_height
  end
end
