class RemoveAllOldColumns < ActiveRecord::Migration
  def up
    remove_column :contents, :old_title
    remove_column :contents, :old_sub_caption
    remove_column :contents, :old_content
    remove_column :contents, :old_caption

    remove_column :embed_media, :old_title
    remove_column :embed_media, :old_url
    remove_column :embed_media, :old_code

    remove_column :media, :old_title
    remove_column :media, :old_caption
    remove_column :media, :old_caption_align
    remove_column :media, :old_source
    remove_column :media, :old_infobox_type

    remove_column :sections, :old_title

    remove_column :slideshows, :old_title
    remove_column :slideshows, :old_caption

    remove_index :stories, :name => "index_stories_on_in_theme_slider"
    remove_index :stories, :name => "index_stories_on_permalink"
    remove_index :stories, :name => "index_stories_on_published"
    remove_index :stories, :name => "index_stories_on_published_at"

    remove_column :stories, :old_title
    remove_column :stories, :old_author
    remove_column :stories, :old_media_author
    remove_column :stories, :old_published
    remove_column :stories, :old_published_at
    remove_column :stories, :old_permalink
    remove_column :stories, :old_about
    remove_column :stories, :old_permalink_staging
    remove_column :stories, :old_in_theme_slider

    remove_column :users, :old_avatar_file_name

    remove_column :youtubes, :old_title
    remove_column :youtubes, :old_url

  end

  def down
    # do nothing
  end
end
