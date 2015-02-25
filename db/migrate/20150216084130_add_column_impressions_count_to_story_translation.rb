class AddColumnImpressionsCountToStoryTranslation < ActiveRecord::Migration
  def change
   add_column :story_translations , :impressions_count, :integer , :default => 0
  end
end
