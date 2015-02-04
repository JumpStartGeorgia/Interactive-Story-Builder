atom_feed do |feed|
  feed.title t('app.common.feed'), :app_name => (t'app.common.app_name_not_trans')
  feed.updated @items.first.published_at

  @items.each do |item|
    feed.entry item, :published => item.published_at, :url => storyteller_show_path(item.permalink,:only_path => false)    do |entry|
      entry.title item.title      
      entry.content(item.about, :type => 'html')      
      item.categories.map {|t|
        entry.category term: t.permalink.downcase, label: t.name, scheme: feed_path(:category => t.permalink.downcase )
      }     
      entry.author do |author|
        author.name item.author
      end
      #entry.logo image_tag(item.show_asset.file.url(:thumbnail)).html_safe 
    end
  end

end
