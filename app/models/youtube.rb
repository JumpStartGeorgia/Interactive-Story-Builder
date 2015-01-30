class Youtube < ActiveRecord::Base
  include TranslationOverride

	translates :title, :url, :menu_lang, :cc, :cc_lang, :code

	belongs_to :section
	has_many :youtube_translations

	accepts_nested_attributes_for :youtube_translations
	attr_accessible :section_id, :fullscreen, :loop, :info, :youtube_translations_attributes
 	alias_attribute  :trans, :youtube_translations

  #################################
  ## Validations
	validates :section_id, :presence => true

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:youtube_translations]
  end

end
