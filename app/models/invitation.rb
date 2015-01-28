class Invitation < ActiveRecord::Base

  belongs_to :story
  belongs_to :from_user, foreign_key: :from_user_id, class_name: "User"
  belongs_to :to_user, foreign_key: :to_user_id, class_name: "User"

  attr_accessible :from_user_id, :key, :story_id, :to_email, :to_user_id, :sent_at, :accepted_at, :message, :role, :translation_locales
	attr_accessor :send_notification
  
  validates :from_user_id, :story_id, :to_email, :role, :presence => true
  validates_format_of :to_email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  
  
  before_create :create_default_values
  
  def self.pending_by_user(user_id)
    includes(:story, :from_user).
    where(['invitations.to_user_id = ? and invitations.accepted_at is null', user_id] )  
  end
 
 
  def create_default_values
    self.key = Devise.friendly_token.first(20) if self.key.blank?
    self.sent_at = Time.now
    return true
  end
  
  # get all editors
  def self.editors
    where(:role => Story::ROLE[:editor])
  end

  # get all translators
  def self.translators
    where(:role => Story::ROLE[:translator])
  end

  def self.pending_by_story(story_id)
    includes(:to_user)
    .where('invitations.accepted_at is null and invitations.story_id = ?', story_id)
  end
  
  def self.delete_invitation(story_id, to_email)
    where(:story_id => story_id, :to_email => to_email).destroy_all
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


end
