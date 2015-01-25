class EmbedMedium < ActiveRecord::Base
  include TranslationOverride

  translates :title, :url, :code

  belongs_to :section

  has_many :embed_medium_translations, :dependent => :destroy
  accepts_nested_attributes_for :embed_medium_translations


  #################################
  ## Validations
	validates :section_id, :presence => true

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:embed_medium_translations]
  end

end
