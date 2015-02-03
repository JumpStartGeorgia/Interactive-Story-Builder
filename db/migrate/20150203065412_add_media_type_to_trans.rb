class AddMediaTypeToTrans < ActiveRecord::Migration
  def up
    add_column :medium_translations, :media_type, :integer, :limit => 1

    # add data from media table
    Medium.transaction do
      Medium.all.each do |medium|
        puts "- medium id #{medium.id}; type = #{medium.media_type}"
        trans = medium.medium_translations.first
        trans.media_type = medium.media_type
        trans.save(validate: false)
      end
    end
  end

  def down
    remove_column :medium_translations, :media_type
  end
end
