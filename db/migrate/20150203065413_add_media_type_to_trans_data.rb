class AddMediaTypeToTransData < ActiveRecord::Migration
  def up
    # add data from media table
    Medium.transaction do
      Medium.all.each do |medium|
        puts "- medium id #{medium.id}; type = #{medium.media_type}"
        medium.medium_translations.each do |trans|
          trans.media_type = medium.media_type
          trans.save(validate: false)
        end
      end
    end
  end

  def down
    MediumTranslation.update_all(:media_type => nil)
  end
end
