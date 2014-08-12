class RemoveOldColumns < ActiveRecord::Migration
  def up
    remove_column :media, "image_file_name_old"
    remove_column :media, "image_content_type_old"
    remove_column :media, "image_file_size_old"
    remove_column :media, "image_updated_at_old"
    remove_column :media, "video_file_name_old"
    remove_column :media, "video_content_type_old"
    remove_column :media, "video_file_size_old"
    remove_column :media, "video_updated_at_old"
    
    remove_column :sections, "audio_file_name_old"
    remove_column :sections, "audio_content_type_old"
    remove_column :sections, "audio_file_size_old"
    remove_column :sections, "audio_updated_at_old"

    remove_column :stories, "thumbnail_old"
    remove_column :stories, "thumbnail_file_name_old"
    remove_column :stories, "thumbnail_content_type_old"
    remove_column :stories, "thumbnail_file_size_old"
    remove_column :stories, "thumbnail_updated_at_old"
    
  end

  def down
     # do nothing
  end
end
