class TranslateSections < ActiveRecord::Migration
  def up
    # rename the existing columns
    rename_column :sections, :title, :old_title

    # create translation table
    Section.create_translation_table! :title => :string

    # move the data using the story_locale as the translation locale
    Story.transaction do
      Story.all.each do |story|
        puts "- id =#{story.id}; locale = #{story.story_locale}"
        Globalize.story_locale = story.story_locale
        story.sections.each do |section|
          puts "-- section id #{section.id}; current_locale = #{section.current_locale}"
          trans = section.translation_for(story.story_locale)
          trans.title = section.old_title
          trans.save
        end        
      end
    end

  end

  def down
    # drop translation table
    Section.drop_translation_table!

    # rename exisitng columns
    rename_column :sections, :old_title, :title

  end
end
