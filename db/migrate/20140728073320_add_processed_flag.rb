class AddProcessedFlag < ActiveRecord::Migration
  def up
    add_column :assets, :processed, :boolean, :default => true
    add_index :assets, :processed 
    
    Asset.where(:asset_type => Asset::TYPE[:media_video]).update_all(:processed => false)
  end
  def down
    remove_index :assets, :processed 
    remove_column :assets, :processed
  end
end
