# encoding: utf-8
module Utf8Converter

	def self.geo
		['ა','ბ','გ','დ','ე','ვ','ზ','თ','ი','კ','ლ','მ','ნ','ო','პ','ჟ',
		'რ','ს','ტ','უ','ფ','ქ','ღ','ყ','შ','ჩ','ც','ძ','წ','ჭ','ხ','ჯ','ჰ']
	end

	def self.eng
		['a','b','g','d','e','v','z','t','i','k','l','m','n','o','p','zh',
		  'r','s','t','u','p','q','gh','kh','sh','ch','ts','dz','ts','tch','kh','j','h']
	end

  # create unique characters for each geo character
	def self.eng_permalink
		['a','b','g','d','e','v','z','t','i','k','l','m','n','o','p','zh',
		  'r','s','th','u','f','q','gh','qkh','sh','ch','c','dz','ts','tch','kh','j','h']
	end

  def self.convert_ka_to_en (text)
    s = text
    geo.each_with_index do |v, i|
      s = s.gsub /#{v}/, eng[i]
    end
    return s
  end

  def self.generate_permalink(text)
    s = text
    geo.each_with_index do |v, i|
      s = s.gsub /#{v}/, eng_permalink[i]
    end
    # remove bad characters
    s = s.gsub(/[^0-9A-Za-z ]/,'').split.join('_')
    return s
  end
end
