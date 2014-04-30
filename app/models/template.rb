class Template < ActiveRecord::Base
	has_many :stories
	attr_accessible :id,:name,:title,:description,:author,:params,:default
	def self.select_list
		select("id, title").order("title asc")
	end
end
