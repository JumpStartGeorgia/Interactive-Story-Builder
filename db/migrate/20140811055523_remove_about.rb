class RemoveAbout < ActiveRecord::Migration
  def up
    Page.where(:name => 'about').destroy_all
  end

  def down
    p = Page.create(:id => 1, :name => 'about')
    p.page_translations.create(:locale => 'en', :title => 'About Story Builder')
    p.page_translations.create(:locale => 'ka', :title => 'Story Builder-ის შესახებ')
  end
end
