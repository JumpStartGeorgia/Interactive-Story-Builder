module StoriesHelper
	def self.transliterate(str)
	  # Based on permalink_fu by Rick Olsen
	  # Escape str by transliterating to UTF-8 with Iconv http://stackoverflow.com/questions/12947910/force-strings-to-utf-8-from-any-encoding
	  #s = Iconv.iconv('ascii//ignore//translit', 'utf-8', str).to_s
	  s = str.force_encoding("UTF-8")
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

	# compute translation progress
	def compute_translation_progress_percent(locale, progress_array)
		percent = nil
		if progress_array.present?
			# get record of story main language
			main = progress_array.select{|x| x.is_story_locale?}.first
			if main.present?
				if main.locale == locale.to_s
					percent = "100%"
				else
					record = progress_array.select{|x| x.locale == locale.to_s}.first
					if record.present?
						percent = number_to_percentage((100 * record.items_completed / main.items_completed), precision: 0)
					end
				end
			end
		end
		return percent
	end

	def preview_image(asset_class, url, pars = {}, visible = true)
		link_to t('app.buttons.preview_image'), "",
			id: "media-image-preview",
      class: "btn btn-default preview preview-translated #{asset_class}",
    	data: {
    		"modalos-id": "modalos-preview",
    		type: "image",
    		"image-path": url,
    	}.merge(pars),
    	style: visible ? nil : "display:none;"
  end

	def preview_video(asset_class, url, processed=false, pars = {}, visible = true)
    if processed || !visible
  		link_to t('app.buttons.preview_video'), "",
  			id: "media-video-preview",
        class: "btn btn-default preview preview-translated #{asset_class}",
      	data: {
      		"modalos-id": "modalos-preview",
      		type: "video",
      		"video-path": url,
      		"video-type": "video/mp4"
      	}.merge(pars),
      	style: visible ? nil : "display:none;"
    end
  end
end
