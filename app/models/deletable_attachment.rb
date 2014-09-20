# taken from http://stackoverflow.com/a/23908552
# allows a checkbox to be used to indicate that a file attachment should be deleted
module DeletableAttachment
  extend ActiveSupport::Concern

  included do
    attachment_definitions.keys.each do |name|

      attr_accessor :"delete_#{name}"

      before_validation { 
        q = send("delete_#{name}")
        x = q == '1' 
        logger.debug "$$$$$$$$$$$$$$$$$$$$$ check if delete asset = #{x}; value = #{q}"
        send(name).clear if send("delete_#{name}") == '1' 
      }

      define_method :"delete_#{name}=" do |value|
        instance_variable_set :"@delete_#{name}", value
        send("#{name}_file_name_will_change!")
      end

    end
  end

end