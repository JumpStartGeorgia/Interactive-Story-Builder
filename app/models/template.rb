class Template < ActiveRecord::Base
	has_many :stories
	attr_accessible :id,:name,:title,:description,:author,:params,:default,:public
	def self.select_list(self_template_id)
		where("public = true || id = #{self_template_id}").select("id, title, description").order("title asc")
	end
end
