# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Template.delete_all
Template.create(id:1,name:"nytimes",title:"NYTimes Template",description:"Taken from NY Times 'Game of Shark and Minow' story",author:"NY TIMES",default:true)
Template.create(id:2,name:"chca",title:"CHCA Template",description:"For CHCA specific story - not suggested for use in other stories",author:"Irakli Chumburidze",default:false,public:false)
Template.create(id:3,name:"chca_en",title:"CHCA Template(en)",description:"For CHCA specific story - not suggested for use in other stories",author:"Irakli Chumburidze",default:false,public:false)


