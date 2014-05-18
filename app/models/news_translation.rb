class NewsTranslation < ActiveRecord::Base
	require 'utf8_converter'
  has_permalink :create_permalink, scope: :locale, :update => true

	belongs_to :news
  attr_accessible :news_id, :title, :content, :locale, :permalink

  validates :title, :content, :presence => true
  
  def required_data_provided?
    provided = false
    
    provided = self.title.present? && self.content.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.title = obj.title if self.title.blank?
    self.content = obj.content if self.content.blank?
  end
  
  def create_permalink
    "#{Utf8Converter.convert_ka_to_en(self.title.clone.to_ascii.gsub(/[^0-9A-Za-z|_\- ]/,''))}"
  end

  
end
