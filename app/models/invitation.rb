class Invitation < ActiveRecord::Base

  belongs_to :story
  belongs_to :form_user, foreign_key: :from_user_id, class_name: "User"
  belongs_to :to_user, foreign_key: :to_user_id, class_name: "User"

  attr_accessible :from_user_id, :key, :story_id, :to_email, :to_user_id, :sent_at, :accepted_at
  
  validates :from_user_id, :story_id, :to_email, :presence => true
  
  
  before_create :create_default_values
  
 
  def create_default_values
    self.key = Devise.friendly_token.first(20) if self.key.blank?
    self.sent_at = Time.now
  end
  
  def self.pending_by_story(story_id)
    includes(:to_user)
    .where('invitations.accepted_at is null and invitations.story_id = ?', story_id)
  end
  
  def self.delete_invitation(story_id, to_email)
    where(:story_id => story_id, :to_email => to_email).destroy_all
  end
end
