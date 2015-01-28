# encoding: UTF-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#####################
## Types
#####################
puts "Loading Types"
StoryType.delete_all
StoryTypeTranslation.delete_all
t = StoryType.create(:id => 1, :sort_order => 1)
t.story_type_translations.create(:locale => 'en', :name => 'Story')
t.story_type_translations.create(:locale => 'ka', :name => 'Story')
t.story_type_translations.create(:locale => 'ru', :name => 'Story')
t.story_type_translations.create(:locale => 'az', :name => 'Story')
t.story_type_translations.create(:locale => 'hy', :name => 'Story')
t = StoryType.create(:id => 2, :sort_order => 2)
t.story_type_translations.create(:locale => 'en', :name => 'Talk Show')
t.story_type_translations.create(:locale => 'ka', :name => 'Talk Show')
t.story_type_translations.create(:locale => 'ru', :name => 'Talk Showy')
t.story_type_translations.create(:locale => 'az', :name => 'Talk Show')
t.story_type_translations.create(:locale => 'hy', :name => 'Talk Show')
t = StoryType.create(:id => 3, :sort_order => 3)
t.story_type_translations.create(:locale => 'en', :name => 'Video')
t.story_type_translations.create(:locale => 'ka', :name => 'Video')
t.story_type_translations.create(:locale => 'ru', :name => 'Video')
t.story_type_translations.create(:locale => 'az', :name => 'Video')
t.story_type_translations.create(:locale => 'hy', :name => 'Video')
t = StoryType.create(:id => 4, :sort_order => 4)
t.story_type_translations.create(:locale => 'en', :name => 'Photo')
t.story_type_translations.create(:locale => 'ka', :name => 'Photo')
t.story_type_translations.create(:locale => 'ru', :name => 'Photo')
t.story_type_translations.create(:locale => 'az', :name => 'Photo')
t.story_type_translations.create(:locale => 'hy', :name => 'Photo')
# t = StoryType.create(:id => 5, :sort_order => 5)
# t.story_type_translations.create(:locale => 'en', :name => 'Infographic')
# t.story_type_translations.create(:locale => 'ka', :name => 'Infographic')
# t.story_type_translations.create(:locale => 'ru', :name => 'Infographic')
# t.story_type_translations.create(:locale => 'az', :name => 'Infographic')
# t.story_type_translations.create(:locale => 'hy', :name => 'Infographic')


#####################
## Languages
#####################
puts 'loading languages'
Language.delete_all
langs = [
  ["af", "Afrikaans"],
  ["sq", "shqipe"],
  ["ar", "العربية‏"],
  ["hy", "Հայերեն"],
  ["az", "Azərbaycan­ılı"],
  ["eu", "euskara"],
  ["be", "Беларускі"],
  ["bg", "български"],
  ["ca", "català"],
  ["hr", "hrvatski"],
  ["cs", "čeština"],
  ["da", "dansk"],
  ["div", "ދިވެހިބަސް‏"],
  ["nl", "Nederlands"],
  ["en", "English"],
  ["et", "eesti"],
  ["fo", "føroyskt"],
  ["fi", "suomi"],
  ["fr", "français"],
  ["gl", "galego"],
  ["ka", "ქართული"],
  ["de", "Deutsch"],
  ["el", "ελληνικά"],
  ["gu", "ગુજરાતી"],
  ["he", "עברית‏"],
  ["hi", "हिंदी"],
  ["hu", "magyar"],
  ["is", "íslenska"],
  ["id", "Bahasa Indonesia"],
  ["it", "italiano"],
  ["ja", "日本語"],
  ["kn", "ಕನ್ನಡ"],
  ["kk", "Қазащb"],
  ["sw", "Kiswahili"],
  ["kok", "कोंकणी"],
  ["ko", "한국어"],
  ["ky", "Кыргыз"],
  ["lv", "latviešu"],
  ["lt", "lietuvių"],
  ["mk", "македонски јазик"],
  ["ms", "Bahasa Malaysia"],
  ["mr", "मराठी"],
  ["mn", "Монгол хэл"],
  ["no", "norsk"],
  ["fa", "فارسى‏"],
  ["pl", "polski"],
  ["pt", "Português"],
  ["pa", "ਪੰਜਾਬੀ"],
  ["ro", "română"],
  ["ru", "русский"],
  ["sa", "संस्कृत"],
  ["sr", "srpski"],
  ["sk", "slovenčina"],
  ["sl", "slovenski"],
  ["es", "español"],
  ["sv", "svenska"],
  ["syr", "ܣܘܪܝܝܐ‏"],
  ["ta", "தமிழ்"],
  ["tt", "Татар"],
  ["te", "తెలుగు"],
  ["th", "ไทย"],
  ["tr", "Türkçe"],
  ["uk", "україньска"],
  ["ur", "اُردو‏"],
  ["uz", "U'zbek"],
  ["vi", "Tiếng Việt"],
  ["zh-TW", "繁體中文"],
  ["zh-CN", "简体中文"]
]

sql = "insert into languages (locale, name) values "
sql << langs.map{|x| "(\"#{x[0]}\", \"#{x[1]}\")"}.join(', ')
ActiveRecord::Base.connection.execute(sql)



#####################
## Themes
#####################
puts "Loading Test Themes"
Theme.delete_all
ThemeTranslation.delete_all
StoryTheme.delete_all

# get stories to add to theme
published_ids = StoryTranslation.select('distinct story_id').where(:published => true)
published = Story.where(:id => published_ids.uniq)
story_types = StoryType.select('id').map{|x| x.id}

t = Theme.create(:ud => 1, :is_published => true, :published_at => '2015-01-15', :show_home_page => true)
t.theme_translations.create(:locale => 'en', :name => '1st test theme', edition: 'January 2015')
t.theme_translations.create(:locale => 'ka', :name => '1st test theme', edition: 'January 2015')
published[0..7].each_with_index do |story, i|
  story.themes << t
  story.story_type_id = story_types.sample
  if i % 2 == 0
    story.in_theme_slider = true
  end
  story.save
end
t = Theme.create(:ud => 2, :is_published => true, :published_at => '2014-12-15')
t.theme_translations.create(:locale => 'en', :name => '2nd test theme', edition: 'December 2014')
t.theme_translations.create(:locale => 'ka', :name => '2nd test theme', edition: 'December 2014')
published[8..10].each_with_index do |story, i|
  story.themes << t
  story.story_type_id = story_types.sample
  if i % 2 == 0
    story.in_theme_slider = true
  end
  story.save
end

t = Theme.create(:ud => 3, :is_published => true, :published_at => '2014-11-15')
t.theme_translations.create(:locale => 'en', :name => '3rd test theme', edition: 'November 2015')
t.theme_translations.create(:locale => 'ka', :name => '3rd test theme', edition: 'November 2015')
published[10..20].each_with_index do |story, i|
  story.themes << t
  story.story_type_id = story_types.sample
  if [1, 5, 9].include?(i)
    story.in_theme_slider = true
  end
  story.save
end

# add story type to remaining stories
published[21..published.length-1].each do |story|
  story.story_type_id = story_types.sample
  story.save
end

# need to make some users authors for testing
User.where(:role => User::ROLES[:user]).limit(7).update_all(:role => User::ROLES[:author])
# need to make some users coordinators for testing
User.where(:role => User::ROLES[:user]).limit(7).update_all(:role => User::ROLES[:coordinator])


#####################
## Pages
#####################
puts "Loading Pages"
Page.delete_all
PageTranslation.delete_all
p = Page.create(:id => 1, :name => 'about')
p.page_translations.create(:locale => 'en', :title => 'About Chai Khana')
p.page_translations.create(:locale => 'ka', :title => 'About Chai Khana')
p.page_translations.create(:locale => 'az', :title => 'About Chai Khana')
p.page_translations.create(:locale => 'ru', :title => 'About Chai Khana')
p.page_translations.create(:locale => 'hy', :title => 'About Chai Khana')


=begin OLD STUFF FROM STORYBUILDER

#####################
## Pages
#####################
# puts "Loading Pages"
Page.delete_all
PageTranslation.delete_all
#p = Page.create(:id => 1, :name => 'about')
#p.page_translations.create(:locale => 'en', :title => 'About Story Builder')
#p.page_translations.create(:locale => 'ka', :title => 'Story Builder-ის შესახებ')
p = Page.create(:id => 2, :name => 'todo')
p.page_translations.create(:locale => 'en', :title => "Story Builder's To-Do List")
p.page_translations.create(:locale => 'ka', :title => 'Story Builder-ის გასაკეთებელი სია')

#####################
## Templates
#####################
puts 'loading templates'
Template.delete_all
Template.create(id:1,name:"nytimes",title:"NYTimes Template",description:"Taken from NY Times 'Game of Shark and Minow' story",author:"NY TIMES",default:true)
Template.create(id:2,name:"chca",title:"CHCA Template",description:"For CHCA specific story - not suggested for use in other stories",author:"Irakli Chumburidze",default:false,public:false)
Template.create(id:3,name:"chca_en",title:"CHCA Template(en)",description:"For CHCA specific story - not suggested for use in other stories",author:"Irakli Chumburidze",default:false,public:false)

#####################
## Languages
#####################
puts 'loading languages'
Language.delete_all
langs = [
  ["af", "Afrikaans"],
  ["sq", "shqipe"],
  ["ar", "العربية‏"],
  ["hy", "Հայերեն"],
  ["az", "Azərbaycan­ılı"],
  ["eu", "euskara"],
  ["be", "Беларускі"],
  ["bg", "български"],
  ["ca", "català"],
  ["hr", "hrvatski"],
  ["cs", "čeština"],
  ["da", "dansk"],
  ["div", "ދިވެހިބަސް‏"],
  ["nl", "Nederlands"],
  ["en", "English"],
  ["et", "eesti"],
  ["fo", "føroyskt"],
  ["fi", "suomi"],
  ["fr", "français"],
  ["gl", "galego"],
  ["ka", "ქართული"],
  ["de", "Deutsch"],
  ["el", "ελληνικά"],
  ["gu", "ગુજરાતી"],
  ["he", "עברית‏"],
  ["hi", "हिंदी"],
  ["hu", "magyar"],
  ["is", "íslenska"],
  ["id", "Bahasa Indonesia"],
  ["it", "italiano"],
  ["ja", "日本語"],
  ["kn", "ಕನ್ನಡ"],
  ["kk", "Қазащb"],
  ["sw", "Kiswahili"],
  ["kok", "कोंकणी"],
  ["ko", "한국어"],
  ["ky", "Кыргыз"],
  ["lv", "latviešu"],
  ["lt", "lietuvių"],
  ["mk", "македонски јазик"],
  ["ms", "Bahasa Malaysia"],
  ["mr", "मराठी"],
  ["mn", "Монгол хэл"],
  ["no", "norsk"],
  ["fa", "فارسى‏"],
  ["pl", "polski"],
  ["pt", "Português"],
  ["pa", "ਪੰਜਾਬੀ"],
  ["ro", "română"],
  ["ru", "русский"],
  ["sa", "संस्कृत"],
  ["sr", "srpski"],
  ["sk", "slovenčina"],
  ["sl", "slovenski"],
  ["es", "español"],
  ["sv", "svenska"],
  ["syr", "ܣܘܪܝܝܐ‏"],
  ["ta", "தமிழ்"],
  ["tt", "Татар"],
  ["te", "తెలుగు"],
  ["th", "ไทย"],
  ["tr", "Türkçe"],
  ["uk", "україньска"],
  ["ur", "اُردو‏"],
  ["uz", "U'zbek"],
  ["vi", "Tiếng Việt"],
  ["zh-TW", "繁體中文"],
  ["zh-CN", "简体中文"],
  ["am", "Հայերեն"]
]]

sql = "insert into languages (locale, name) values "
sql << langs.map{|x| "(\"#{x[0]}\", \"#{x[1]}\")"}.join(', ')
ActiveRecord::Base.connection.execute(sql)
# update count of languages with published stories
Language.update_counts

#####################
## Categories
#####################
puts "Loading Categories"
Category.delete_all
CategoryTranslation.delete_all
cat = Category.create(:id => 1)
cat.category_translations.create(:locale => 'ka', :name => 'კულტურა')
cat.category_translations.create(:locale => 'en', :name => 'Culture')
cat = Category.create(:id => 2)
cat.category_translations.create(:locale => 'ka', :name => 'თავდაცვა')
cat.category_translations.create(:locale => 'en', :name => 'Defence / Security')
cat = Category.create(:id => 3)
cat.category_translations.create(:locale => 'ka', :name => 'ეკონომიკა / ბიზნესი')
cat.category_translations.create(:locale => 'en', :name => 'Economy / Business')
cat = Category.create(:id => 4)
cat.category_translations.create(:locale => 'ka', :name => 'განათლება')
cat.category_translations.create(:locale => 'en', :name => 'Education')
cat = Category.create(:id => 5)
cat.category_translations.create(:locale => 'ka', :name => 'გარემო ')
cat.category_translations.create(:locale => 'en', :name => 'Environment')
cat = Category.create(:id => 6)
cat.category_translations.create(:locale => 'ka', :name => 'სამზარეულო')
cat.category_translations.create(:locale => 'en', :name => 'Food')
cat = Category.create(:id => 7)
cat.category_translations.create(:locale => 'ka', :name => 'გენდერი')
cat.category_translations.create(:locale => 'en', :name => 'Gender')
cat = Category.create(:id => 8)
cat.category_translations.create(:locale => 'ka', :name => 'ჯანმრთელობა')
cat.category_translations.create(:locale => 'en', :name => 'Health')
cat = Category.create(:id => 9)
cat.category_translations.create(:locale => 'ka', :name => 'ისტორია')
cat.category_translations.create(:locale => 'en', :name => 'History')
cat = Category.create(:id => 10)
cat.category_translations.create(:locale => 'ka', :name => 'როგორ')
cat.category_translations.create(:locale => 'en', :name => 'How To / DIY')
cat = Category.create(:id => 11)
cat.category_translations.create(:locale => 'ka', :name => 'იუმორი')
cat.category_translations.create(:locale => 'en', :name => 'Humor')
cat = Category.create(:id => 12)
cat.category_translations.create(:locale => 'ka', :name => 'მარლთმსაჯულება')
cat.category_translations.create(:locale => 'en', :name => 'Justice')
cat = Category.create(:id => 13)
cat.category_translations.create(:locale => 'ka', :name => 'ცხოვრების წესი')
cat.category_translations.create(:locale => 'en', :name => 'Lifestyle')
cat = Category.create(:id => 14)
cat.category_translations.create(:locale => 'ka', :name => 'პოლიტიკა')
cat.category_translations.create(:locale => 'en', :name => 'Politics')
cat = Category.create(:id => 15)
cat.category_translations.create(:locale => 'ka', :name => 'საზოგადოებრივი უსაფრთხოება')
cat.category_translations.create(:locale => 'en', :name => 'Public Saftey')
cat = Category.create(:id => 16)
cat.category_translations.create(:locale => 'ka', :name => 'მეცნიერება')
cat.category_translations.create(:locale => 'en', :name => 'Science')
# update count of categories with published stories
Category.update_counts

=end