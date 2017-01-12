class CreateContentSectionBasedOnStoryAboutForPhotoAndStoryType < ActiveRecord::Migration
  def up
    require "./lib/text.rb"
    white = TextSimilarity::WhiteSimilarity.new
    stories = Story.where(story_type_id: [1,4])#.where(id: 353)
    puts "Stories to process: #{stories.length}"
    stories.each {|story|
      I18n.locale = story.story_locale
      story.current_locale = story.story_locale
      story_about_orig = ActionController::Base.helpers.sanitize ActionController::Base.helpers.strip_tags story.about
      puts "  #{story.title}"
      if !story_about_orig.present?
        puts "--------- original about is missing"
        next 
      end
      story_about_orig = story_about_orig
      secs = story.sections.select{|t| t.ok? }.sort_by{ |p| p.position }
      similar_section = nil
      secs.each { |sec|
        if sec.content?
          section_text = ActionController::Base.helpers.sanitize ActionController::Base.helpers.strip_tags sec.content.text
          ratio = white.similarity(story_about_orig, section_text)
          similar_section = sec if ratio > 0.90
        end
      }
      if similar_section.nil?      
        new_section = Section.create(story_id: story.id, type_id: 1, has_marker: 0, title: "story_about_text" )
        new_section.move_to_top
        new_content = Content.create(:section_id => new_section.id, title: "about", text: ("<p>" + story_about_orig + "</p>"))
        pl = story.published_locales
        pl.each {|l|
          next if l == story.story_locale
          ls = l.to_sym        
          story.current_locale = ls
          new_content.current_locale = ls
          new_section.current_locale = ls
          story_about = "<p>" + (story.about.present? ?  (ActionController::Base.helpers.sanitize ActionController::Base.helpers.strip_tags story.about) : story_about_orig)  + "</p>"      
          new_section.update_attributes({title: "story_about_text"})        
          new_content.update_attributes({title: "about", text: story_about })           
        }
    else
      puts "--------- already existent content with about text"      
     end
    }
  end

  def down    
    stories = Story.where(story_type_id: [1,4])#.where(id: 353)
    puts "Stories to process: #{stories.length}"
    stories.each {|story|
      puts "  #{story.title}"
      secs = story.sections.select{|t| t.content? && t.title == "story_about_text" && t.content.title == "about" }.first
      if secs.present?
        secs.destroy
      else
        puts "--------- already without about text content"      
      end
    }
  end
end
