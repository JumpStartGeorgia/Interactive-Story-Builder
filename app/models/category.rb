class Category < ActiveRecord::Base
	translates :name, :permalink
	require 'utf8_converter'

	has_many :story_categories, :dependent => :destroy
	has_many :stories, :through => :story_categories
	has_many :category_translations, :dependent => :destroy
  accepts_nested_attributes_for :category_translations

  attr_accessible :id, :category_translations_attributes

	def self.sorted
		with_translations(I18n.locale).order("category_translations.name asc")
	end

end
