class UpdateStoryTemplateIdToDefault < ActiveRecord::Migration
  def up
  	Story.where("template_id is null").update_all(template_id: 1)
  end

  def down
  end
end
