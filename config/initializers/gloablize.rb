# use story_locale to record the locale of the story and make it available to all of it's sub-parts
module Globalize

  class << self
    def story_locale
      @story_locale || self.locale.to_s
    end

    def story_locale=(locale)
      @story_locale = locale.to_s
    end
  end

end

module Globalize
  module ActiveRecord
    module InstanceMethods

      # if this is a story translation use the current_locale
      def translation
        if is_story_translation == true
          translation_for(current_locale)
        else
          translation_for(::Globalize.locale)
        end
      end

      def translations_for(v)
        v.each{ |t| translation_for(t) }     
      end

      # flag to indicate if translation is for story
      # - if so, then use current_locale instead before Globalize.locale
      def is_story_translation=(bool)
        @is_story_translation = bool
      end

      def is_story_translation
        x = @is_story_translation.nil? ? false : @is_story_translation
        # puts "========= globalize is_story_translation = #{x}"
        return x
      end

      # locale to use for translation
      def current_locale=(current_locale)
        @current_locale = current_locale
      end

      def current_locale
        x = @current_locale.present? ? @current_locale : self.read_attribute(:story_locale).present? && self.story_locale.present? ? self.story_locale : Globalize.story_locale
        # puts "========= globalize current locale = #{x}; @current = #{@current_locale}; attr present = #{self.read_attribute(:story_locale).present?}; story locale = #{self.story_locale if self.read_attribute(:story_locale).present?}; globalize story locale = #{Globalize.story_locale}"
        return x
      end

      # override to use current_locale if is story translation
      def write_attribute(name, value, options = {})
        if translated?(name)
          # Deprecate old use of locale
          unless options.is_a?(Hash)
            warn "[DEPRECATION] passing 'locale' as #{options.inspect} is deprecated. Please use {:locale => #{options.inspect}} instead."
            options = {:locale => options}
          end
          options = is_story_translation == true ? {:locale => current_locale}.merge(options) : {:locale => Globalize.locale}.merge(options)
          
          # Dirty tracking, paraphrased from
          # ActiveRecord::AttributeMethods::Dirty#write_attribute.
          name_str = name.to_s
          if attribute_changed?(name_str)
            # If there's already a change, delete it if this undoes the change.
            old = changed_attributes[name_str]
            changed_attributes.delete(name_str) if value == old
          else
            # If there's not a change yet, record it.
            old = globalize.fetch(options[:locale], name)
            old = old.clone if old.duplicable?
            changed_attributes[name_str] = old if value != old
          end
          
          globalize.write(options[:locale], name, value)
        else
          super(name, value)
        end
      end

      # override to use current_locale if is story translation
      def read_attribute(name, options = {})
        # Deprecate old use of locale
        unless options.is_a?(Hash)
          warn "[DEPRECATION] passing 'locale' as #{options.inspect} is deprecated. Please use {:locale => #{options.inspect}} instead."
          options = {:locale => options}
        end

        options = {:translated => true, :locale => nil}.merge(options)
        if self.class.translated?(name) and options[:translated]
          if (is_story_translation == true && value = globalize.fetch(options[:locale] || current_locale, name))
            value
          elsif (is_story_translation == false && value = globalize.fetch(options[:locale] || Globalize.locale, name))
            value
          else
            super(name)
          end
        else
          super(name)
        end
      end
    end
  end
end

# module Globalize
#   module ActiveRecord
#     class Adapter

#       def fetch_attribute(locale, name)
#         puts "&&&&&&&&&&&& fetch_attribute"
#         translation = record.translation_for(locale, false)
#         return translation && translation.send(name)
#       end

#     end
#   end
# end

# want to allow all field types, not just string and text
module Globalize
  module ActiveRecord
    module Migration
      class Migrator
        def valid_field_type?(name, type)
#          !translated_attribute_names.include?(name) || [:string, :text].include?(type)
          translated_attribute_names.include?(name)
        end
      end
    end
  end
end


