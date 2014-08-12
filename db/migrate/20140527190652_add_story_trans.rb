class AddStoryTrans < ActiveRecord::Migration
  def up
		Story.create_translation_table! :shortened_url => :string
  end

  def down
		Story.drop_translation_table!
  end
end
