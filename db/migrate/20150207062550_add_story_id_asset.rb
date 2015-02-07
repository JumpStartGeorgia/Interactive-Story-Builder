class AddStoryIdAsset < ActiveRecord::Migration
  def up
    # add_column :assets, :avatar_id, :string
    # add_column :assets, :story_id, :integer
    # rename_column :users, :avatar_file_name, :old_avatar_file_name

    story_types = [Asset::TYPE[:story_thumbnail], Asset::TYPE[:section_audio], Asset::TYPE[:media_image], Asset::TYPE[:media_video], Asset::TYPE[:slideshow_image]]

    # add story/avatar id to assets
    Asset.transaction do
      Asset.all.each do |asset|
        puts "asset id #{asset.id}, asset type #{asset.asset_type}"
        if story_types.include?(asset.asset_type)
          asset.set_file_id
        elsif asset.asset_type == Asset::TYPE[:user_avatar]
          asset.avatar_id = asset.user.old_avatar_file_name
        end
        asset.save
      end
    end
  end

  def down
    remove_column :assets, :avatar_id
    remove_column :assets, :story_id
    rename_column :users, :old_avatar_file_name, :avatar_file_name
  end
end
