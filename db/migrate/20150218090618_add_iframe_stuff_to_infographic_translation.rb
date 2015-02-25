class AddIframeStuffToInfographicTranslation < ActiveRecord::Migration
  def change
    add_column :infographic_translations, :dynamic_url, :string
    add_column :infographic_translations, :dynamic_code, :text
    add_column :infographic_translations, :dynamic_width, :integer, :default => 0
    add_column :infographic_translations, :dynamic_height, :integer, :default => 0
  end
end
