class AddStoryPermalink2 < ActiveRecord::Migration
  def up
    add_column :stories, :permalink_staging, :string
    
    Story.transaction do 
      Story.all.each do |story|
        story.permalink_staging = story.title
        story.save
      end
    end
  end

  def down
    remove_column :stories, :permalink_staging
  end
end
