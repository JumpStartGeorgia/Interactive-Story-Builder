class AddTemplateIdDefault < ActiveRecord::Migration
  def up
  	  change_column :stories, :template_id, :integer, :default => 1
  end

  def down
  	  change_column :stories, :template_id, :integer, :default => 1
  end
end