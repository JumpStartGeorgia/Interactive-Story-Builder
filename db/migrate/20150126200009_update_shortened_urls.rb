class UpdateShortenedUrls < ActiveRecord::Migration
  def up
    # if story translation has shortened url but not title, delete the record
    # else re-create the url to make sure it is using the correct locale
    StoryTranslation.transaction do
      StoryTranslation.order('story_id').each do |trans|
        puts "trans id #{trans.id}"
        if trans.title.blank? 
          puts " ----- deleting"
          trans.delete
        elsif trans.permalink.present? && !Rails.env.development?
          puts " +++++ creating url"
          trans.generate_shortened_url
          trans.save
        end        
      end
    end
  end

  def down
    # do nothing    
  end
end
