# if using nested_form to upload files and want all files for a record under one folder
# replace 'xxx_id' with the name of the object parameter name that you want to use as the folder name
Paperclip.interpolates('story_id') do |attachment, style|
  attachment.instance.section.story_id
end

