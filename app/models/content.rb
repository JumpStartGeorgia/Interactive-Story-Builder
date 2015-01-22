class Content < ActiveRecord::Base
  include TranslationOverride

  translates :title, :caption, :sub_caption, :text

	belongs_to :section	 

  has_many :content_translations, :dependent => :destroy
  accepts_nested_attributes_for :content_translations
  attr_accessible :content_translations_attributes

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:content_translations]
  end

  #################################
  ## Validations
	validates :section_id, :presence => true
	

  #################################
	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end
end
