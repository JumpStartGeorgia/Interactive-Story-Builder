class Section < ActiveRecord::Base
	belongs_to :story
	has_one :content
	has_many :media  
	TYPE = {content: 1, media: 2}
	
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
