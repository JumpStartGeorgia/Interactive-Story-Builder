class GeneratePosters < ActiveRecord::Migration
  def up
    Medium.where('video_file_name is not null').each do |m|
      m.video.reprocess! if m.video.exists?
    end
  end

  def down
    # do nothing
  end
end
