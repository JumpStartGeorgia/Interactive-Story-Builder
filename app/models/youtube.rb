class Youtube < ActiveRecord::Base
  	belongs_to :section

  	has_many :youtube_translations

  	validates :youtube_translations, :presence => true

  	attr_accessible :section_id, :title, :url, :fullscreen, :loop, :info, :youtube_translations_attributes

	validates :section_id, :title, :url, :presence => true
	validates :url, :format => {:with => URI::regexp(['http','https'])}, :if => "!url.blank?"

	accepts_nested_attributes_for :youtube_translations

end
