xml.instruct!
xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do

  xml.channel do
    xml.title 'Story Builder RSS Channel'
    xml.description 'Storybuilder\'s published stories with about story text'
    xml.link root_url
    xml.language 'en'
    xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => rss_path
    xml.filtered_by  @filtered_by_tag != "" ? "tag = " + @filtered_by_tag :  ""
    xml.filtered_by  @filtered_by_category != "" ? "category = " + @filtered_by_category :  ""
    for t in @stories
      xml.item do
        xml.title t.title
        xml.link storyteller_show_path(t.permalink,:only_path => false)
        xml.pubDate(t.created_at.rfc2822)
        xml.guid t.id
        xml.description(h(t.about))
      end
    end

  end

end