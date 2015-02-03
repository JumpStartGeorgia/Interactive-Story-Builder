class TranslateSlideshow < ActiveRecord::Migration
  def up
    # add missing index
    add_index :slideshows, :section_id
    
    # rename the existing columns
    rename_column :slideshows, :title, :old_title
    rename_column :slideshows, :caption, :old_caption

    # create translation table
    Slideshow.create_translation_table! :title => :string, :caption => :string

    # move the data using the story_locale as the translation locale
    Story.transaction do
      Slideshow.all.each do |slideshow|
        locale = I18n.default_locale
        if slideshow.section.present? and slideshow.section.story.present?
          locale = slideshow.section.story.story_locale 
          puts "- locale = #{locale}; slideshow id = #{slideshow.id}"
        else
          puts "---> could not find the story for this record #{slideshow.id}, defaulting to locale #{locale}"
        end
        trans = slideshow.translation_for(locale)
        trans.title = slideshow.old_title
        trans.caption = slideshow.old_caption
        trans.save
      end

      # Story.all.each do |story|
      #   puts "- id =#{story.id}; locale = #{story.story_locale}"
      #   Globalize.story_locale = story.story_locale
      #   story.sections.each do |section|
      #     if section.slideshow? 
      #       # somehow it is possible that there is more than one record per section so have to manually get the records
      #       Slideshow.where(section_id: section.id).each do |slideshow|
      #         puts "-- section id #{section.id}, slideshow id = #{slideshow.id}; current_locale = #{section.current_locale}"
      #         trans = slideshow.translation_for(story.story_locale)
      #         trans.title = slideshow.old_title
      #         trans.caption = slideshow.old_caption
      #         trans.save
      #       end
      #     end
      #   end        
      # end
    end

  end

  def down
    # remove missing index
    remove_index :slideshows, :section_id

    # drop translation table
    Slideshow.drop_translation_table!

    # rename exisitng columns
    rename_column :slideshows, :old_title, :title
    rename_column :slideshows, :old_caption, :caption

  end
end
