class AddAssetAspectratioToAsset < ActiveRecord::Migration
  def up
    add_column :assets, :asset_aspectratio, :float
    assets = Asset.where(asset_type: 4)
    assets.each do |a|
      if a.asset.exists?
        a.asset_aspectratio = Paperclip::Geometry.from_file(a.asset.path(:fullscreen)).aspect.round(2)
        a.save
      end
    end
  end

  def down
     remove_column :assets, :asset_aspectratio
  end

end
