class AddPreviewKey < ActiveRecord::Migration
  def up
    add_column :stories, :reviewer_key, :integer
    add_index :stories, :reviewer_key
    
    Story.transaction do
      # add key to each story on file already
      Story.all.each do |s|
        s.generate_reviewer_key
        s.save
      end 
    end
  end

  def down
    remove_column :stories, :reviewer_key
  end
end
