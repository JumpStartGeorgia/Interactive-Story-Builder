class StoryType < ActiveRecord::Base
  translates :name, :permalink

  has_many :story_type_translations, :dependent => :destroy
  accepts_nested_attributes_for :story_type_translations
  attr_accessible :id, :sort_order, :story_type_translations_attributes

  def self.sorted
    with_translations(I18n.locale).order('story_types.sort_order, story_type_translations.name')
  end
  
end
