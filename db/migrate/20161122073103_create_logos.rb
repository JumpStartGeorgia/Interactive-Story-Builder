class CreateLogos < ActiveRecord::Migration
  def up
    create_table :logos do |t|
      t.integer :logo_type
      t.string :url
      t.boolean :is_active, default: true
      t.integer :position, default: 99

      t.timestamps
    end
    add_index :logos, :is_active
    add_index :logos, :position
    add_attachment :logos, :image

    # add logos
    require 'csv'
    Logo.transaction do
      path = "#{Rails.root}/db/logos/"
      logos = CSV.read("#{path}logos.csv")
      logos[1..-1].each do |logo|
        puts logo[1]
        if File.exists? "#{path}#{logo[1]}" 
          Logo.create(
            logo_type: logo[0],
            image: File.open("#{path}#{logo[1]}"),
            url: logo[2],
            position: logo[3]
          )
        else
          puts "!!!!!!!!!! could not find #{logo[1]}"
        end
      end

      # update the about text to remove the html that had the logos in it
      text = Page.by_name('about')
      text.page_translations.each do |trans|
        index = trans.content.index("<h2>#{I18n.t("app.common.logo_types.sponsors", locale: trans.locale)}</h2>")
        trans.content = trans.content[0..index-1]
        trans.save
      end
    end
  end

  def down
    Logo.destroy_all
    drop_table :logos

    # update the about text to remove the html that had the logos in it
    text = Page.by_name('about')
    text.page_translations.each do |trans|
      trans.content = trans.content + '<h2>' + I18n.t("app.common.logo_types.sponsors", locale: trans.locale) + '</h2>
<div class="about-logos">
<div class="about-logo">
<p><a href="http://mymedia.org.ua/" target="_blank"><img src="/assets/mymedia-logo-en.jpg" alt="MYMEDIA logo" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://www.gov.uk/world/georgia" target="_blank"><img src="/assets/sponsor2.png" alt="" width="200px" /></a></p>
</div>
</div>
<h2>' + I18n.t("app.common.logo_types.partners", locale: trans.locale) + '</h2>
<div class="about-logos">
<div class="about-logo">
<p><a href="http://women-peace.net/" target="_blank"><img src="/assets/partners/women-peacenet.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://www.bbc.com/azeri" target="_blank"><img src="/assets/partners/bbc_azer.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://1tv.ge/ge/tvshows/view/328.html" target="_blank"><img src="/assets/partners/comunicatoryi.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://civilnet.am" target="_blank"><img src="/assets/partners/civil.net.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://media.ge" target="_blank"><img src="/assets/partners/mediage.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://www.aravot.am" target="_blank"><img src="/assets/partners/unmuns.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://netgazeti.ge" target="_blank"><img src="/assets/partners/netgazeti.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://medialab.am" target="_blank"><img src="/assets/partners/medialab.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://www.a1plus.am" target="_blank"><img src="/assets/partners/u1.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://on.ge" target="_blank"><img src="/assets/partners/onge.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://reporter.ge" target="_blank"><img src="/assets/partners/region_network.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="http://www.azadliq.org" target="_blank"><img src="/assets/partners/radioliberty_azer.png" alt="" width="200px" /></a></p>
</div>
<div class="about-logo">
<p><a href="https://globalvoices.org" target="_blank"><img src="/assets/partners/globalvoices.png" alt="" width="200px" /></a></p>
</div>
</div>'
      trans.save
    end

    
  end
end
