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
      Story.all.each do |story|
        puts "- id =#{story.id}; locale = #{story.story_locale}"
        story.sections.each do |section|
          if section.slideshow? && section.slideshow.present?
            puts "-- section id #{section.id}, slideshow id = #{section.slideshow.id}"
            trans = section.slideshow.slideshow_translations.build(:locale => story.story_locale)
            trans.title = section.slideshow.old_title
            trans.caption = section.slideshow.old_caption
            trans.save
          end
        end        
      end
    end

  end

  def down
    # drop translation table
    Slideshow.drop_translation_table!

    # rename exisitng columns
    rename_column :slideshows, :old_title, :title
    rename_column :slideshows, :old_caption, :caption

  end
end
