class Youtube < ActiveRecord::Base
	translates :menu_lang, :cc, :cc_lang, :code
	before_save :generate_iframe

  	belongs_to :section

  	has_many :youtube_translations

  	validates :youtube_translations, :presence => true

  	attr_accessible :section_id, :title, :url, :fullscreen, :loop, :info, :youtube_translations_attributes
 	alias_attribute  :trans, :youtube_translations
	validates :section_id, :title, :url, :presence => true
	validates :url, :format => {:with => URI::regexp(['http','https'])}, :if => "!url.blank?"

	accepts_nested_attributes_for :youtube_translations

	def generate_iframe
		id = ''
		html = ''
		ok = false
		u = self.url 
		if u.present?
			uri = URI.parse(u)
			if(uri.host.nil? && u.length == 11)
			  id = u
			else
			  uri = /^(?:http(?:s)?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:(?:watch)?\?(?:.*&)?v(?:i)?=|(?:embed|v|vi|user)\/))([^\?&\"'>]+)/.match(u)
			  if(uri[1].length == 11)
			    id = uri[1]
			  end
			end
			if id.length == 11         
			  source = 'https://www.googleapis.com/youtube/v3/videos?key=AIzaSyA5DU2KQn3u4mzw6z1YNIHGGr9wadv9vZM&part=id&id=' + id
			  result = JSON.parse(Net::HTTP.get_response(URI.parse(source)).body)

			  pars = (self.loop ? 'loop=1' : '') + (self.info == false ? '&showinfo=0' : '') +
			    (self.cc ? '&cc_load_policy=' + (self.cc ? '1' : '0') : '') + 
			    (Language.select{|x| x.locale == self.menu_lang}.length > 0 ? '&hl=' + self.menu_lang : '') + 
			    (Language.select{|x| x.locale == self.cc_lang}.length > 0 ? '&cc_lang_pref=' + self.cc_lang : '')
			  pars.slice!(0) if pars[0]=='&'
			  	if result['items'].present?
			  		html =  '<iframe width="640" height="360" src="http://www.youtube.com/embed/' + 
			      	    id + '?' + pars + '" frameborder="0" allowfullscreen class="embed-video embed-youtube"></iframe>' 
			  		ok = true
		  		end
			end
		end
		if ok 
			# if do just self.code, it will create a brand new translation record since the new translation record does not exist yet
			# so have to directly reference the translations object to get to the existing record
			if self.youtube_translations.present?
				self.youtube_translations.first.code = html
			else
				self.code = html
			end
		else
			 errors.add(:code, "value can't be generated.")
			 false
		end
	end
end
