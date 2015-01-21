# ignore the first step that gets all translations on record - just want to get the one that is a match
module Globalize
  module ActiveRecord
    module InstanceMethods

      def translation_for(locale, build_if_missing = true)
        unless translation_caches[locale]
          # Fetch translations from database as those in the translation collection may be incomplete
          # _translation = translations.detect{|t| t.locale.to_s == locale.to_s}
          _translation ||= translations.with_locale(locale).first unless translations.loaded?
          _translation ||= translations.build(:locale => locale) if build_if_missing
          translation_caches[locale] = _translation if _translation
        end
        translation_caches[locale]
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
