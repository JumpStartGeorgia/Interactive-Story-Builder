class RenamePublishedToPublicForTemplates < ActiveRecord::Migration
  def change
  	rename_column :templates, :published, :public 
  end
end
