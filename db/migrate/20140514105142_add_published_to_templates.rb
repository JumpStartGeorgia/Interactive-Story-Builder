class AddPublishedToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :published, :boolean,  :default => true    
  end
end
