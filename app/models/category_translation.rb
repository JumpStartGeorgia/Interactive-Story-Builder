class CategoryTranslation < ActiveRecord::Base
	belongs_to :category
  has_permalink :create_permalink, true

  attr_accessible :category_id, :name, :locale

  validates :name, :presence => true
  validates_uniqueness_of :category_id, scope: [:locale]
  def required_data_provided?
    provided = false
    
    provided = self.name.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name if self.name.blank?
  end


  def create_permalink
    self.name.downcase.dup.latinize.to_ascii.gsub(/[^0-9A-Za-z|_\- ]/,'')
  end


end
