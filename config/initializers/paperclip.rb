# if using nested_form to upload files and want all files for a record under one folder
# replace 'xxx_id' with the name of the object parameter name that you want to use as the folder name
Paperclip.interpolates('story_id') do |attachment, style|
  attachment.instance.section.story_id
end
Paperclip.interpolates('storyid_from_parent') do |attachment, style|
  attachment.instance.section.story_id
end

# Paperclip.interpolates('asset_url') do |attachment, style|
#   Rails.logger.debug(attachment.instance.asset_type.to_s)

#   case attachment.instance.asset_type
#       when Asset::TYPE['story_thumbnail']
#    		"/system/places/thumbnail/:id/:style/:basename.:extension"                 
#       when  Asset::TYPE['section_audio']
#         "/system/places/audio/:story_id2/:basename.:extension"
#     end
# end
# Paperclip.interpolates('asset_default_url') do |attachment, style|
#   Rails.logger.debug(attachment.instance.asset_type.to_s)
#   case attachment.instance.asset_type
#       when Asset::TYPE['story_thumbnail']   	
#  		"/assets/missing/250x250/missing.png"            
#       when  Asset::TYPE['section_audio']
#        ""
#     end
# end




