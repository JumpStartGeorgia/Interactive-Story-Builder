class InfographicTranslation < ActiveRecord::Base
  belongs_to :infographic

  has_one :image,     
    :conditions => "asset_type = #{Asset::TYPE[:infographic]}",    
    foreign_key: :item_id,
    class_name: "Asset",
    dependent: :destroy

  has_one :dataset_file,     
    :conditions => "asset_type = #{Asset::TYPE[:infographic_dataset]}",    
    foreign_key: :item_id,
    class_name: "Asset",
    dependent: :destroy

  has_many :infographic_datasources, :dependent => :destroy
  accepts_nested_attributes_for :infographic_datasources

  accepts_nested_attributes_for :image, :reject_if => lambda { |c| c[:asset].blank? && c[:asset_clone_id].blank? }
  accepts_nested_attributes_for :dataset_file, :reject_if => lambda { |c| c[:asset].blank? && c[:asset_clone_id].blank? }

  attr_accessible :infographic_id, :locale, :title, :caption, :description, :dataset_url, 
                  :image_attributes, :dataset_file_attributes, :infographic_datasources_attributes, :subtype

  attr_accessor :is_progress_increment, :progress_story_id

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}    
  validates :image, presence: true
  validates :dataset_url, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('errors.messages.invalid_format_url') }, :if => "!dataset_url.blank?"

  #################################
  # settings to clone story
  amoeba do
    enable

    clone [:image, :dataset_file]
  end

  #################################

  def image_exists?
    self.image.present? && self.image.file.exists?
  end  

  def dataset_file_exists?
    self.dataset_file.present? && self.dataset_file.file.exists?
  end  

private
  def static_type?    
    self.subtype == Infographic::TYPE[:static]
  end
  def dynamic_type?    
    self.subtype == Infographic::TYPE[:dynamic]
  end

end
