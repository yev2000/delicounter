# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

u1 = Fabricate(:user)
u2 = Fabricate(:user)

Fabricate(:question, user: u1)
Fabricate(:question, user: u1, claimed: true)
Fabricate(:question, user: u2)
Fabricate(:question, user: u2)

