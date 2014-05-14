class Template < ActiveRecord::Base
	has_many :stories
	attr_accessible :id,:name,:title,:description,:author,:params,:default
	def self.select_list
		where("published = true").select("id, title, description").order("title asc")
	end
end
