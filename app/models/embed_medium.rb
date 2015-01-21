class EmbedMedium < ActiveRecord::Base
  translates :title, :url, :code

  belongs_to :section

  has_many :embed_medium_translations, :dependent => :destroy
  accepts_nested_attributes_for :embed_medium_translations
  attr_accessible :embed_medium_translations_attributes


  #################################
  ## Validations
	validates :section_id, :presence => true
end
