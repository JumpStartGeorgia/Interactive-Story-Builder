class RenameSubTypeToAssetSubtype < ActiveRecord::Migration
  def change
  	rename_column :assets, :subtype, :asset_subtype
  end
end
