# encoding: UTF-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#####################
## Templates
#####################
puts 'loading templates'
Template.delete_all
Template.create(id:1,name:"nytimes",title:"NYTimes Template",description:"Taken from NY Times 'Game of Shark and Minow' story",author:"NY TIMES",default:true)
Template.create(id:2,name:"chca",title:"CHCA Template",description:"For CHCA specific story - not suggested for use in other stories",author:"Irakli Chumburidze",default:false,public:false)


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
  ["vi", "Tiếng Việt"]
]

sql = "insert into languages (locale, name) values "
sql << langs.map{|x| "(\"#{x[0]}\", \"#{x[1]}\")"}.join(', ')
ActiveRecord::Base.connection.execute(sql)

