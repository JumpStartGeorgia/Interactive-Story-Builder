class UpdateAssetItemId < ActiveRecord::Migration
  def up

    Asset.transaction do
      Asset.all.each do |asset|
        puts "asset id #{asset.id}; asset type = #{asset.asset_type}; item id = #{asset.item_id}"
        
        # use to record the new item id that is from the translation record
        new_item_id = nil

        # add story id to asset
        case asset.asset_type
          when Asset::TYPE[:user_avatar]        
            # do nothing for user item id is the same

          when Asset::TYPE[:story_thumbnail]        
            story = Story.select('id, story_locale').find_by_id(asset.item_id)
            if story.present?
              puts "- found story"
              # get the new item id from the translation record
              trans = story.translation_for(story.story_locale)
              new_item_id = trans.id if trans.present?
            else
              puts "-- story not found"
              raise ActiveRecord::Rollback
              return
            end

          when  Asset::TYPE[:section_audio]         
            section = Section.select('id, story_id').find_by_id(asset.item_id)
            if section.present?
              puts "- found section"
              # get the new item id from the translation record
              trans = section.translation_for(section.story.story_locale)
              new_item_id = trans.id if trans.present?
            else
              puts "-- section not found"
              raise ActiveRecord::Rollback
              return
            end

          when  Asset::TYPE[:media_image]        
            section = Section.select('sections.id, sections.story_id').joins(:media).where(media: {id: asset.item_id}).first
            if section.present?
              puts "- found section"
              # get the new item id from the translation record
              trans = MediumTranslation.where(medium_id: asset.item_id, locale: section.story.story_locale).first
              new_item_id = trans.id if trans.present?
            else
              puts "-- section not found"
              raise ActiveRecord::Rollback
              return
            end

          when  Asset::TYPE[:media_video]        
            section = Section.select('sections.id, sections.story_id').joins(:media).where(media: {id: asset.item_id}).first
            if section.present?
              puts "- found section"
              # get the new item id from the translation record
              trans = MediumTranslation.where(medium_id: asset.item_id, locale: section.story.story_locale).first
              new_item_id = trans.id if trans.present?
            else
              puts "-- section not found"
              raise ActiveRecord::Rollback
              return
            end

           when  Asset::TYPE[:slideshow_image]        
            section = Section.select('sections.id, sections.story_id').joins(:slideshow).where(slideshows: {id: asset.item_id}).first
            if section.present?
              puts "- found section"
              # get the new item id from the translation record
              trans = SlideshowTranslation.where(slideshow_id: asset.item_id, locale: section.story.story_locale).first
              new_item_id = trans.id if trans.present?
            else
              puts "-- section not found"
              # raise ActiveRecord::Rollback
              # return
            end
        end

        if new_item_id.present?
          asset.item_id = new_item_id
          x = asset.save(validate: false)
          puts "- save success = '#{x}'; #{asset.errors.full_messages.to_sentence}"
        end
      end
    end
  end

  def down
    # reset item id back to id of main record

    Asset.transaction do
      Asset.all.each do |asset|
        puts "asset id #{asset.id}; asset type = #{asset.asset_type}; item id = #{asset.item_id}"
        
        # use to record the new item id that is from the translation record
        new_item_id = nil

        # add story id to asset
        case asset.asset_type
          when Asset::TYPE[:user_avatar]        
            # do nothing for user item id is the same

          when Asset::TYPE[:story_thumbnail]        
            trans = StoryTranslation.select('id, story_id').find_by_id(asset.item_id)
            if trans.present?
              puts "- found story"
              new_item_id = trans.story_id
            else
              puts "-- story not found"
              raise ActiveRecord::Rollback
              return
            end

          when  Asset::TYPE[:section_audio]         
            trans = SectionTranslation.select('id, section_id').find_by_id(asset.item_id)
            if trans.present?
              puts "- found section"
              new_item_id = trans.section_id
            else
              puts "-- section not found"
              raise ActiveRecord::Rollback
              return
            end

          when  Asset::TYPE[:media_image]        
            trans = MediumTranslation.where(id: asset.item_id).first
            if trans.present?
              puts "- found section"
              # get the new item id from the translation record
              new_item_id = trans.medium_id
            else
              puts "-- section not found"
              raise ActiveRecord::Rollback
              return
            end

          when  Asset::TYPE[:media_video]        
            trans = MediumTranslation.where(id: asset.item_id).first
            if section.present?
              puts "- found section"
              # get the new item id from the translation record
              new_item_id = trans.medium_id
            else
              puts "-- section not found"
              raise ActiveRecord::Rollback
              return
            end

           when  Asset::TYPE[:slideshow_image]        
            trans = SlideshowTranslation.where(id: asset.item_id).first
            if section.present?
              puts "- found section"
              # get the new item id from the translation record
              new_item_id = trans.slideshow_id
            else
              puts "-- section not found"
              assets_to_delete << asset.id
            end
        end

        if new_item_id.present?
          asset.item_id = new_item_id
          x = asset.save(validate: false)
          puts "- save success = '#{x}'; #{asset.errors.full_messages.to_sentence}"
        end
      end
    end
  end
end
