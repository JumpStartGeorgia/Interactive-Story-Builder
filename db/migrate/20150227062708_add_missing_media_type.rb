class AddMissingMediaType < ActiveRecord::Migration
  def up
    MediumTranslation.transaction do
      # add missing media type to media translation tables
      MediumTranslation.where('media_type is null').each do |trans|
        puts "trans id = #{trans.id} and media type should be #{trans.medium.media_type}"
        trans.media_type = trans.medium.media_type
        trans.save
      end
    end
  end

  def down
    # do nothing
  end
end
