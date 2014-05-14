module StoriesHelper
	def self.transliterate(str)
	  # Based on permalink_fu by Rick Olsen
	     Rails.logger.debug("--------------------str-------------------------------#{str}")
	  # Escape str by transliterating to UTF-8 with Iconv http://stackoverflow.com/questions/12947910/force-strings-to-utf-8-from-any-encoding
	  #s = Iconv.iconv('ascii//ignore//translit', 'utf-8', str).to_s
	  s = str.force_encoding("UTF-8")
	   Rails.logger.debug("--------------------s-------------------------------#{s}")
	  # Downcase string
	  s.downcase!
	 
	  # Remove apostrophes so isn't changes to isnt
	  s.gsub!(/'/, '')
	 
	  # Replace any non-letter or non-number character with a space
	  s.gsub!(/[^[[:alnum:]]]+/, ' ')
	 
	  # Remove spaces from beginning and end of string
	  s.strip!
	 
	  # Replace groups of spaces with single hyphen
	  s.gsub!(/\ +/, '-')
	 
	  return s
	end
	def self.transliterate_path( filename )
	  extension = File.extname(filename).gsub(/^\.+/, '')  
	  filename = filename.gsub(/\.#{extension}$/, '')

	  "#{StoriesHelper.transliterate(filename)}.#{StoriesHelper.transliterate(extension)}"
	end
end
