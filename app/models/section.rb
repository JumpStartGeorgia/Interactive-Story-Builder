class Section < ActiveRecord::Base
	belongs_to :story
	has_one :content
	has_many :media, :order => 'position'
  acts_as_list scope: :story

	TYPE = {content: 1, media: 2}
  
  amoeba do
    enable
    clone [:content, :media]
  end

  validates :story_id, :presence => true
  validates :type_id, :presence => true, :inclusion => { :in => TYPE.values }  
  validates :title, :presence => true, length: { maximum: 255, :message => 'Title max length is 255 symbols' } 	
  validates :has_marker, :presence => true, :inclusion => { :in => [1,0] }  
  #validates :audio, :presence

	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end

   def get_str_type
   	 TYPE.keys[TYPE.values.index(self.type_id)]
   end
   def content?
   	 TYPE[:content] == self.type_id	
   end
 def media?
   	 TYPE[:media] == self.type_id	
   end

end
