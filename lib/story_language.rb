module StoryLanguage
  # assign the language to a story if one match is found and it is reliable
  # - start by analyzing titles
  # - if titles are not enough, look at the story content
  def self.assign
    Story.transaction do
      stories = Story.order('title asc')
      titles = stories.map{|x| x.title}
      
      langs = DetectLanguage.detect(titles)
      
      if langs.present? && stories.length == langs.length
        (0..stories.length-1).each do |index|
          puts "-------------"
          lang = langs[index]
          
          puts "title #{stories[index].title}; #{lang}"

          # if the title has many words and only one reliable result is returned, use it
          if stories[index].title.split(' ').length > 2 && lang.length == 1 && lang[0]["isReliable"] == true
            puts "- setting story locale to #{lang[0]["language"]}"
            stories[index].story_locale = lang[0]["language"]
            stories[index].save(:validate => false)
          else
            # if story has content, send content to get language
            content_section_ids = Section.select('id').where(:story_id => stories[index].id, :type_id => Section::TYPE[:content])            
            if content_section_ids.present?
              assigned_lang = false
              content_section_ids.each do |section_id|
                # if content exists, get it and test it
                contents = Content.select('content').where(['section_id = ? and content is not null and content != ""', section_id]).limit(1).first
                if contents.present?
                  # strip out all tags and any &xxx; html text
                  content = ActionController::Base.helpers.strip_tags(contents.content).gsub(/&.{4,10}\;/, '')
                  content_lang = DetectLanguage.detect(content) 
                  puts "- content lang #{content}; #{content_lang}"
                  if content_lang.present? && content_lang.length == 1 && content_lang[0]["isReliable"] == true
                    puts "- setting story locale to #{content_lang[0]["language"]}"
                    stories[index].story_locale = content_lang[0]["language"]
                    stories[index].save(:validate => false)
                    assigned_lang = true
                    break
                  end
                end
              end
              if !assigned_lang
                puts "--> could not reliably detect story language"
              end
            else
              puts "--> story has no content"
            end
          end
      
        end

        # update the language counts for all published stories
        Language.update_counts
      end
    end
  end
end
