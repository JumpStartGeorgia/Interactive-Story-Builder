class StoryTypeTranslation < ActiveRecord::Base
  belongs_to :story_type
  has_permalink :create_permalink

  attr_accessible :story_type_id, :name, :permalink, :locale

  validates :name, :presence => true

  # permalink is name
  def create_permalink   
    self.name.latinize.to_ascii.gsub(/[^0-9A-Za-z|_\- ]/,'')
  end

  def required_data_provided?
    provided = false
    
    provided = self.name.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name if self.name.blank?
  end

end
