class TemplateIdToStory < ActiveRecord::Migration
  def change
  	add_column :stories, :template_id, :integer
  end
end
