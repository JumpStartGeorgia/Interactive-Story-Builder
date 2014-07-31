class Page < ActiveRecord::Base
	translates :title, :content

	has_many :page_translations, :dependent => :destroy
  accepts_nested_attributes_for :page_translations
  attr_accessible :id, :name, :page_translations_attributes
  
  validates :name, :presence => true

  def self.by_name(name)
    with_translations(I18n.locale).find_by_name(name)
  end

end

