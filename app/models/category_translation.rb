class CategoryTranslation < ActiveRecord::Base
	require 'utf8_converter'
	belongs_to :category
  has_permalink :create_permalink, scope: :locale

  attr_accessible :category_id, :name, :locale

  validates :name, :presence => true

  def required_data_provided?
    provided = false
    
    provided = self.name.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name if self.name.blank?
  end


  def permalink
#    Utf8Converter.convert_ka_to_en(self.name.downcase.gsub(" ","_").gsub("/","_").gsub("__","_").gsub("__","_"))
    Utf8Converter.convert_ka_to_en(self.name.downcase.clone.to_ascii.gsub(/[^0-9A-Za-z|_\- ]/,''))
  end


end
