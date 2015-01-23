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
end
