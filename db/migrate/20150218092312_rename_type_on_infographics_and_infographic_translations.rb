class RenameTypeOnInfographicsAndInfographicTranslations < ActiveRecord::Migration
   def change
      rename_column :infographics, :type, :subtype
      rename_column :infographic_translations, :type, :subtype
   end
end
