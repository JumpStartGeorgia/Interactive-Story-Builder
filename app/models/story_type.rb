class StoryType < ActiveRecord::Base
  translates :name, :permalink

  has_many :story_type_translations, :dependent => :destroy
  has_many :stories
  accepts_nested_attributes_for :story_type_translations
  attr_accessible :id, :sort_order, :story_type_translations_attributes

  def self.sorted
    with_translations(I18n.locale).order('story_types.sort_order, story_type_translations.name')
  end

  def self.find_by_permalink(permalink)
    joins(:story_type_translations).where("`story_type_translations`.`permalink` = ? or exists(select 'a' from `friendly_id_slugs` where `friendly_id_slugs`.`sluggable_type` = 'StoryTypeTranslation' and `friendly_id_slugs`.`sluggable_id` = `story_type_translations`.`id` and `friendly_id_slugs`.`slug` = ?)", permalink, permalink).first
  end
end
