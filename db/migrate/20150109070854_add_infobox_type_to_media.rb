class AddInfoboxTypeToMedia < ActiveRecord::Migration
  def change
  	  add_column :media, :infobox_type, :integer, :default => 0 # 0 ordinary, 1 fixed bottom box
  end
end
