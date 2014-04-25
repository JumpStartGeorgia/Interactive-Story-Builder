class Section < ActiveRecord::Base
	belongs_to :story
	has_one :content, dependent: :destroy
  has_one :asset,     
  :conditions => "asset_type = #{Asset::TYPE[:section_audio]}",    
  foreign_key: :item_id,
  dependent: :destroy

	has_many :media, :order => 'position', dependent: :destroy
  acts_as_list scope: :story

  

	TYPE = {content: 1, media: 2}
 
  accepts_nested_attributes_for :asset

  amoeba do
    enable
    clone [:content, :media]
  end

  validates :story_id, :presence => true
  validates :type_id, :presence => true, :inclusion => { :in => TYPE.values }  
  validates :title, :presence => true, length: { maximum: 255, :message => 'Title max length is 255 symbols' } 	

	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end
 before_post_process :transliterate_file_name
   def get_str_type
   	 TYPE.keys[TYPE.values.index(self.type_id)]
   end
   def content?
   	 TYPE[:content] == self.type_id	
   end
 def media?
   	 TYPE[:media] == self.type_id	
   end

  

 private

def transliterate_file_name
  if audio_file_name.present?
    extension = File.extname(audio_file_name).gsub(/^\.+/, '')
    filename = audio_file_name.gsub(/\.#{extension}$/, '')
    self.audio.instance_write(:file_name, "#{StoriesHelper.transliterate(filename)}.#{StoriesHelper.transliterate(extension)}")
  end
end

end
