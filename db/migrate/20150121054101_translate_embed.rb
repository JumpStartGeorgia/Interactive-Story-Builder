class TranslateEmbed < ActiveRecord::Migration
  def up
    # rename the existing columns
    rename_column :embed_media, :title, :old_title
    rename_column :embed_media, :url, :old_url
    rename_column :embed_media, :code, :old_code

    # create translation table
    EmbedMedium.create_translation_table! :title => :string, :url => :string, :code => :text

    # move the data using the story_locale as the translation locale
    Story.transaction do
      EmbedMedium.all.each do |embed|
        locale = I18n.default_locale
        if embed.section.present? and embed.section.story.present?
          locale = embed.section.story.story_locale 
          puts "- locale = #{locale}; embed id = #{embed.id}"
        else
          puts "---> could not find the story for this record #{content.id}, defaulting to locale #{locale}"
        end
        trans = embed.translation_for(locale)
        trans.title = embed.old_title
        trans.url = embed.old_url
        trans.code = embed.old_code
        trans.save
      end

      # Story.all.each do |story|
      #   puts "- id =#{story.id}; locale = #{story.story_locale}"
      #   Globalize.story_locale = story.story_locale
      #   story.sections.each do |section|
      #     if section.embed_media?
      #       # somehow it is possible that there is more than one record per section so have to manually get the records
      #       EmbedMedium.where(section_id: section.id).each do |embed|
      #         puts "-- section id #{section.id}, embed_medium id = #{embed.id}; current_locale = #{section.current_locale}"
      #         trans = embed.translation_for(story.story_locale)
      #         trans.title = embed.old_title
      #         trans.url = embed.old_url
      #         trans.code = embed.old_code
      #         trans.save
      #       end
      #     end
      #   end        
      # end
    end

  end

  def down
    # drop translation table
    EmbedMedium.drop_translation_table!

    # rename exisitng columns
    rename_column :embed_media, :old_title, :title
    rename_column :embed_media, :old_url, :url
    rename_column :embed_media, :old_code, :code

  end
end
