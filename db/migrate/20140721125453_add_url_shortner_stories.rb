class AddUrlShortnerStories < ActiveRecord::Migration
  def up
		Story.create_translation_table! :shortened_url => :string
    
    # create url for existing published stories
    Story.transaction do 
      Story.is_published.each_with_index do |story, index|
        puts "processing story #{story.id} | #{story.title} | #{index} of #{story.length} "
        story.generate_shortened_url
        story.save
      end
    end
  end

  def down
		Story.drop_translation_table!
  end
end
