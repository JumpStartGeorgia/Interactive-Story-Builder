class CreateContentSectionBasedOnStoryAboutForPhotoAndStoryType < ActiveRecord::Migration
  def up
    require "./lib/text.rb"
    white = TextSimilarity::WhiteSimilarity.new
    stories = Story.where(story_type_id: [2,3,4,5])#.where(id: 359)
    puts "Stories to process: #{stories.length}"
    stories.each { |story|
      I18n.locale = story.story_locale
      story.current_locale = story.story_locale

      story_about_orig = (Nokogiri::HTML.parse story.about).text # ActionController::Base.helpers.sanitize ActionController::Base.helpers.strip_tags
      puts "#{story.id} - #{story.title}"
      if !story.published || !story_about_orig.present?
        puts "--------- original about is missing"
        next
      end
      # story_about_orig = story_about_orig
      secs = story.sections.sort_by{ |p| p.position } #.select{|t| t.ok? }
      similar_section = nil
      first_section = secs.first
      if first_section.present?
        secs.each { |sec|
          if sec.content?
            section_text = (Nokogiri::HTML.parse sec.content.text).text
            ratio = white.similarity(story_about_orig, section_text)
            similar_section = sec if ratio > 0.90
          end
        }
        if similar_section.nil?
          if !first_section.infographic?
            new_section = Section.create(story_id: story.id, type_id: 1, has_marker: 0, title: "story_about_text" )

            if first_section.media?
              puts "--------- moving as second"
              new_section.insert_at(2)
            else
              puts "--------- moving as first"
              new_section.move_to_top
            end

            new_content = Content.create(:section_id => new_section.id, title: "about", text: ("<p>" + story_about_orig + "</p>"))
            pl = story.story_locales
            pl.each {|l|
              next if l == story.story_locale
              ls = l.to_sym
              story.current_locale = ls
              new_content.current_locale = ls
              new_section.current_locale = ls
              if story.about.present?
                story_about = "<p>" + (Nokogiri::HTML.parse story.about).text + "</p>"
                new_section.update_attributes({title: "story_about_text"})
                new_content.update_attributes({title: "about", text: story_about })
              end
            }
          else
            puts "--------- infographic"
            pl = story.story_locales
            pl.each {|l|
              ls = l.to_sym
              story.current_locale = ls
              first_section.current_locale = ls
              if story.about.present?
                cont = first_section.infographic
                cont.current_locale = ls
                cont.update_attributes({description: "<p>" + (Nokogiri::HTML.parse story.about).text  + "</p>" + cont.description })
              end
            }
          end
        else
          puts "--------- already existent content with about text"
        end
      end
    }
  end

  def down
    stories = Story.where(story_type_id: [2,3,4,5])#.where(id: 359)
    puts "Stories to process: #{stories.length}"
    stories.each {|story|
      I18n.locale = story.story_locale
      story.current_locale = story.story_locale

      puts "  #{story.title}"
      secs = story.sections.select{|t| t.content? && t.title == "story_about_text" && t.content.title == "about" }.first
      if secs.present?
        secs.destroy
        puts "--------- had story about text as section"
      else

        first_section = story.sections.sort_by{ |p| p.position }.first #.select{|t| t.ok? }
        if first_section.present? && first_section.infographic?
          pl = story.story_locales
          pl.each {|l|
            ls = l.to_sym
            story.current_locale = ls
            first_section.current_locale = ls
            if story.about.present?
              story_about_text = (Nokogiri::HTML.parse story.about).text
              cont = first_section.infographic
              cont.current_locale = ls
              section_text = cont.description
              if section_text.index("<p>"+story_about_text+"</p>").present?
                cont.update_attributes({ description: section_text.gsub("<p>"+story_about_text+"</p>", "") })
                puts "--------- infographic description had story about"
              end
            end
          }
        else
          puts "--------- already without about text content"
        end
      end
    }
  end
end
