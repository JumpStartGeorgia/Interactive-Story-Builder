class RenameAttachmentsFromModels < ActiveRecord::Migration
  def change
    rename_column :stories, :thumbnail, :thumbnail_old
    rename_column :stories, :thumbnail_file_name, :thumbnail_file_name_old
    rename_column :stories, :thumbnail_content_type, :thumbnail_content_type_old
    rename_column :stories, :thumbnail_file_size, :thumbnail_file_size_old
    rename_column :stories, :thumbnail_updated_at, :thumbnail_updated_at_old

    rename_column :sections, :audio_file_name, :audio_file_name_old
    rename_column :sections, :audio_content_type, :audio_content_type_old
    rename_column :sections, :audio_file_size, :audio_file_size_old
    rename_column :sections, :audio_updated_at, :audio_updated_at_old   


    rename_column :media, :image_file_name, :image_file_name_old   
    rename_column :media, :image_content_type, :image_content_type_old   
    rename_column :media, :image_file_size, :image_file_size_old   
    rename_column :media, :image_updated_at, :image_updated_at_old   
    rename_column :media, :video_file_name, :video_file_name_old   
    rename_column :media, :video_content_type, :video_content_type_old   
    rename_column :media, :video_file_size, :video_file_size_old   
    rename_column :media, :video_updated_at, :video_updated_at_old   
  end
end
