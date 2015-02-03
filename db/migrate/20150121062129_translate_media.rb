class TranslateMedia < ActiveRecord::Migration
  def up
    # rename the existing columns
    rename_column :media, :title, :old_title
    rename_column :media, :caption, :old_caption
    rename_column :media, :caption_align, :old_caption_align
    rename_column :media, :source, :old_source
    rename_column :media, :infobox_type, :old_infobox_type

    # create translation table
    Medium.create_translation_table! :title => :string, :caption => :string, :caption_align => :integer, :source => :string, :infobox_type => :integer

    # move the data using the story_locale as the translation locale
    Story.transaction do
      Medium.all.each do |medium|
        locale = I18n.default_locale
        if medium.section.present? and medium.section.story.present?
          locale = medium.section.story.story_locale 
          puts "- locale = #{locale}; medium id = #{medium.id}"
        else
          puts "---> could not find the story for this record #{content.id}, defaulting to locale #{locale}"
        end
        trans = medium.translation_for(locale)
        trans.title = medium.old_title
        trans.caption = medium.old_caption
        trans.caption_align = medium.old_caption_align
        trans.source = medium.old_source
        trans.infobox_type = medium.old_infobox_type
        trans.save

      end

      # Story.all.each do |story|
      #   puts "- id =#{story.id}; locale = #{story.story_locale}"
      #   Globalize.story_locale = story.story_locale
      #   story.sections.each do |section|
      #     if section.media?
      #       section.media.each do |medium|
      #         puts "-- section id #{section.id}, medium id = #{medium.id}; current_locale = #{section.current_locale}"
      #         trans = medium.translation_for(story.story_locale)
      #         trans.title = medium.old_title
      #         trans.caption = medium.old_caption
      #         trans.caption_align = medium.old_caption_align
      #         trans.source = medium.old_source
      #         trans.infobox_type = medium.old_infobox_type
      #         trans.save
      #       end
      #     end
      #   end        
      # end
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
