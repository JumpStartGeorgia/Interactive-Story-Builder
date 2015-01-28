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

end