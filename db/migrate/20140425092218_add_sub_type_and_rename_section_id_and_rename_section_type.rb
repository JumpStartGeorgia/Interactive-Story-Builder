class AddSubTypeAndRenameSectionIdAndRenameSectionType < ActiveRecord::Migration
  def up
  	 add_column :assets, :subtype, :integer , :limit => 4, :default => 0
 	 rename_column :assets, :section_id, :item_id
 	 rename_column :assets, :section_type, :type

  end

  def down
  	remove_column :assets, :subtype
 	rename_column :assets, :item_id, :section_id
 	rename_column :assets, :type, :section_type
  end
end 