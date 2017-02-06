class Highlight < ActiveRecord::Base
  translates :caption, :url

  before_save :unselect_all_picks

  has_one :image,
    :conditions => "asset_type = #{Asset::TYPE[:highlight]}",
    foreign_key: :item_id,
    class_name: "Asset",
    dependent: :destroy

  has_many :highlight_translations, :dependent => :destroy
  accepts_nested_attributes_for :highlight_translations
  accepts_nested_attributes_for :image, :reject_if => lambda { |c| c[:asset].blank? }

  attr_accessible :id, :picked, :highlight_translations_attributes, :image_attributes

  scope :only_picked, where(picked: true)

  def unselect_all_picks
    Highlight.update_all(picked: false) if self.picked_changed?
  end
  def self.sorted
    with_translations(I18n.locale).order("highlight_translations.updated_at asc")
  end

  # get the url to the avatar
  # - check if using a provider and if so return that avatar url
  # - else use the local avatar
  # if neither exists, return the missing url
  def image_url(style = :slider)
    if self.image.present? && self.image.asset.exists?
      self.image.file.url(style)
    else
      Asset.new(:asset_type => Asset::TYPE[:highlight]).file.url(style)
    end
  end

  def self.picked
    only_picked.first
  end
end
