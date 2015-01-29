class StoryUser < ActiveRecord::Base
  belongs_to :story
  belongs_to :user

  #################################
  ## Validations
  validates :story_id, :user_id, :role, :presence => true

  #################################
  ## Scopes
  scope :sorted, order('created_at desc')

  #################################
  # get all editors
  def self.editors
    where(:role => Story::ROLE[:editor])
  end

  # get all translators
  def self.translators
    where(:role => Story::ROLE[:translator])
  end

  # get record for user
  def self.by_user(user_id)
    where(:user_id => user_id).first
  end

  #################################
  def role_name
    name = ''
    index = Story::ROLE.values.index(self.role)
    if index.present?
      name = I18n.t("story_role.#{Story::ROLE.keys[index].to_s}") 
    end
    return name
  end

  def translation_locales_array
    self.translation_locales.split(',') if translation_locales.present?
  end
end