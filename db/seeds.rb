# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Template.delete_all
Template.create(id:1,name:"nytimes",title:"NYTimes Template",description:"Was taken from nytimes article",author:"NYTIMES",default:true)
Template.create(id:2,name:"irakli",title:"Irakli Chumburidze Inspiration",description:"Was build while creating story for CHCA",author:"Irakli Chumburidze",default:false)


