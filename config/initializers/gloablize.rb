# use story_locale to record the locale of the story and make it available to all of it's sub-parts
module Globalize

  class << self
    def story_locale
      @story_locale || locale
    end

    def story_locale=(locale)
      @story_locale = locale
    end
  end

end

module Globalize
  module ActiveRecord
    module InstanceMethods

      # ignore the first step that gets all translations on record - just want to get the one that is a match
      def translation_for_custom(locale, build_if_missing = true)
        unless translation_caches[locale]
          # Fetch translations from database as those in the translation collection may be incomplete
          # _translation = translations.detect{|t| t.locale.to_s == locale.to_s}
          _translation ||= translations.with_locale(locale).first unless translations.loaded?
          _translation ||= translations.build(:locale => locale) if build_if_missing
          translation_caches[locale] = _translation if _translation
        end
        translation_caches[locale]
      end      


      # flag to indicate if translation is for story
      # - if so, then use current_locale instead before Globalize.locale
      def is_story_translation=(bool)
        @is_story_translation = bool
      end

      def is_story_translation
        x = @is_story_translation.nil? ? false : @is_story_translation
        puts "========= globalize is_story_translation = #{x}"
        return x
      end

      # locale to use for translation
      def current_locale=(current_locale)
        @current_locale = current_locale
      end

      def current_locale
        x = @current_locale.present? ? @current_locale : self.read_attribute(:story_locale).present? && self.story_locale.present? ? self.story_locale : Globalize.story_locale
        puts "========= globalize current locale = #{x}"
        return x
      end

      # override to use current_locale if is story translation
      def write_attribute(name, value, options = {})
        return super(name, value) unless translated?(name)

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
          old = old.dup if old.duplicable?
          changed_attributes[name_str] = old if value != old
        end

        globalize.write(options[:locale], name, value)
      end

      # override to use current_locale if is story translation
      def read_attribute(name, options = {})
        options = {:translated => true, :locale => nil}.merge(options)
        return super(name) unless options[:translated]

        if name == :locale
          self.try(:locale).presence || self.translation.locale
        elsif self.class.translated?(name)
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
