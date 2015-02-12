class ThemeFeature < ActiveRecord::Base
  belongs_to :theme
  belongs_to :featured_story, class_name: "Story", primary_key: :id, foreign_key: :story_id


  acts_as_list scope: :theme

  attr_accessible :position, :story_id, :theme_id

  #################################
  ## Validations
  validates :story_id, :theme_id, :presence => true

end
