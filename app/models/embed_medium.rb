class EmbedMedium < ActiveRecord::Base
  belongs_to :section

  validates :section_id, :title, :url, :code, :presence => true
	validates :url, :format => {:with => URI::regexp(['http','https'])}, :if => "!url.blank?"
  
end
