class TranslateMedia < ActiveRecord::Migration
  def up
    # rename the existing columns
    rename_column :media, :title, :old_title
    rename_column :media, :caption, :old_caption
    rename_column :media, :caption_align, :old_caption_align
    rename_column :media, :source, :old_source
    rename_column :media, :infobox_type, :old_infobox_type

    # create translation table
    Medium.create_translation_table! :title => :string, :caption => :string, :caption_align => :string, :source => :string, :infobox_type => :string

    # move the data using the story_locale as the translation locale
    Story.transaction do
      Story.all.each do |story|
        puts "- id =#{story.id}; locale = #{story.story_locale}"
        story.sections.each do |section|
          if section.media? && section.media.present?
            section.media.each do |medium|
              puts "-- section id #{section.id}, medium id = #{medium.id}"
              trans = medium.medium_translations.build(:locale => story.story_locale)
              trans.title = medium.old_title
              trans.caption = medium.old_caption
              trans.caption_align = medium.old_caption_align
              trans.source = medium.old_source
              trans.infobox_type = medium.old_infobox_type
              trans.save
            end
          end
        end        
      end
    end

  end

  def down
    # drop translation table
    Medium.drop_translation_table!

    # rename exisitng columns
    rename_column :media, :old_title, :title
    rename_column :media, :old_caption, :caption
    rename_column :media, :old_caption_align, :caption_align
    rename_column :media, :old_source, :source
    rename_column :media, :old_infobox_type, :infobox_type

  end
end
