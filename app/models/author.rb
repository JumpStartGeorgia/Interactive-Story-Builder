class Author < ActiveRecord::Base
  translates :name, :about, :permalink

  has_one :avatar,
    :conditions => "asset_type = #{Asset::TYPE[:author_avatar]}",
    foreign_key: :item_id,
    class_name: "Asset",
    dependent: :destroy

  has_many :story_authors
  has_many :stories, :through => :story_authors
  has_many :author_translations, :dependent => :destroy
  accepts_nested_attributes_for :author_translations
  accepts_nested_attributes_for :avatar, :reject_if => lambda { |c| c[:asset].blank? }

  attr_accessible :id, :author_translations_attributes, :avatar_attributes

  scoped_search :in => :author_translations, :on => [:name]

  def self.sorted
    with_translations(I18n.locale).order("author_translations.name asc")
  end

  # get the url to the avatar
  # - check if using a provider and if so return that avatar url
  # - else use the local avatar
  # if neither exists, return the missing url
  def avatar_url(style = :'50x50')
    if self.avatar.present? && self.avatar.asset.exists?
      self.avatar.file.url(style)
    else
      Asset.new(:asset_type => Asset::TYPE[:author_avatar]).file.url(style)
    end
  end

  def self.find_by_permalink(permalink)
    joins(:author_translations).where("`author_translations`.`permalink` = ? or exists(select 'a' from `friendly_id_slugs` where `friendly_id_slugs`.`sluggable_type` = 'AuthorTranslation' and `friendly_id_slugs`.`sluggable_id` = `author_translations`.`id` and `friendly_id_slugs`.`slug` = ?)", permalink, permalink).first
  end
end
