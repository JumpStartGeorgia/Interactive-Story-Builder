class MigrateStoryTemplateIdToUseDefault1ExceptChca < ActiveRecord::Migration
  def up
  	Story.transaction do 
		Story.update_all(template_id: 1)
		Story.update(10, template_id: 2)
	end
  end
  def down
  end
end
