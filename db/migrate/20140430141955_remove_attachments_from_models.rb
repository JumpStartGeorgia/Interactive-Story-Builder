class RemoveAttachmentsFromModels < ActiveRecord::Migration
  def change
  	remove_column :stories, :thumbnail
  	remove_column :stories, :thumbnail_file_name
  	remove_column :stories, :thumbnail_content_type
  	remove_column :stories, :thumbnail_file_size
  	remove_column :stories, :thumbnail_updated_at

  	remove_column :sections, :audio_file_name
  	remove_column :sections, :audio_content_type
  	remove_column :sections, :audio_file_size
  	remove_column :sections, :audio_updated_at   


	remove_column :media, :image_file_name   
	remove_column :media, :image_content_type   
	remove_column :media, :image_file_size   
	remove_column :media, :image_updated_at   
	remove_column :media, :video_file_name   
	remove_column :media, :video_content_type   
	remove_column :media, :video_file_size   
	remove_column :media, :video_updated_at   
  end
end
