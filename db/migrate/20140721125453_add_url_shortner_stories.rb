class AddUrlShortnerStories < ActiveRecord::Migration
  def up
		Story.create_translation_table! :shortened_url => :string
    
    # create url for existing published stories
    Story.transaction do 
      stories = Story.is_published
      stories.each_with_index do |story, index|
        puts "-----"
        puts "processing story #{story.id} | #{story.title} | #{index} of #{stories.length} "
        story.generate_shortened_url
        story.save
      end
    end
  end

  def down
		Story.drop_translation_table!
  end
end
