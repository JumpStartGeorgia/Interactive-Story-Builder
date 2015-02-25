class AddAssetCloneField < ActiveRecord::Migration
  def change
    add_column :assets, :asset_clone_id, :integer
    add_index :assets, :asset_clone_id
  end

end
