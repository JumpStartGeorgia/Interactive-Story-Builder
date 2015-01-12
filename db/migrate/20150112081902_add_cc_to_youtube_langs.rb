class AddCcToYoutubeLangs < ActiveRecord::Migration
  def change
    add_column :youtube_langs, :cc, :boolean
  end
end
