class Youtube < ActiveRecord::Base
  	belongs_to :section

  	attr_accessible :section_id, :title, :url, :video_settings_id

	validates :section_id, :title, :url, :presence => true
	validates :url, :format => {:with => URI::regexp(['http','https'])}, :if => "!url.blank?"

  	has_one :video_settings,     
		foreign_key: :youtube_id,
		class_name: "VideoSettings",
		dependent: :destroy

	accepts_nested_attributes_for :video_settings
end
