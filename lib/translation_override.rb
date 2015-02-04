module TranslationOverride
 extend ActiveSupport::Concern

  included do
    after_find :set_flag
    after_initialize :set_flag
  end

  def set_flag
    # tell globalize that this is a story translation and to use the story locale instead of I18n.locale
    self.is_story_translation = true
    # record the story locale to make it available to the story's sub-parts
    Globalize.story_locale = self.current_locale
  end

  # if the record has a translation for the current app locale, switch to that, 
  # else, leave the current_locale value as it is
  def use_app_locale_if_translation_exists
    Rails.logger.debug "%%%%%%%%%%% translated locales = #{self.translated_locales}; includes? #{self.translated_locales.include?(I18n.locale)}"
    self.current_locale = I18n.locale if self.translated_locales.include?(I18n.locale)
    Globalize.story_locale = self.current_locale
    Rails.logger.debug "%%%%%%%%%%% - current locale = #{self.current_locale}"    
  end
end
