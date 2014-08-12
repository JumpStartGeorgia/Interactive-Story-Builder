# encoding: utf-8
require 'uri'
require 'paperclip/url_generator'
require 'active_support/deprecation'

# if using nested_form to upload files and want all files for a record under one folder
# replace 'xxx_id' with the name of the object parameter name that you want to use as the folder name
Paperclip.interpolates('item_id') do |attachment, style|
  attachment.instance.item_id
end
Paperclip.interpolates('story_id') do |attachment, style|
  attachment.instance.section.story_id
end
Paperclip.interpolates('storyid_from_parent') do |attachment, style|
  attachment.instance.section.story_id
end
Paperclip.interpolates('media_image_story_id') do |attachment, style|
  attachment.instance.image.section.story_id
end
Paperclip.interpolates('media_video_story_id') do |attachment, style|
  attachment.instance.video.section.story_id
end
Paperclip.interpolates('slideshow_image_story_id') do |attachment, style|
  attachment.instance.slideshow.section.story_id
end
Paperclip.interpolates('user_avatar_file_name') do |attachment, style|
  attachment.instance.user.avatar_file_name
end



include ActionView::Helpers::NumberHelper
module Paperclip
   module Validators
      class AttachmentSizeValidator < ActiveModel::Validations::NumericalityValidator
         def human_size(size)
           if defined?(ActiveSupport::NumberHelper) # Rails 4.0+
             ActiveSupport::NumberHelper.number_to_human_size(size)
           else
               number_to_human_size(size)
           end
         end
      end
   end
end