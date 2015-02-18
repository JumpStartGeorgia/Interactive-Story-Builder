class AddTypeToInfographicTranslation < ActiveRecord::Migration
  def change
    add_column :infographic_translations, :type, :integer
  end
end
