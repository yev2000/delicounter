# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

u1 = Fabricate(:user)
u2 = Fabricate(:user)
u3 = Fabricate(:user)
u4 = Fabricate(:user)

Fabricate(:question, user: u1)
Fabricate(:question, user: u1, claimed: true)
3.times { Fabricate(:question, user: u2) }
6.times { Fabricate(:question, user: u3) }
4.times { Fabricate(:question, user: u4) }

admin = Fabricate(:admin, username: "admin", password: "admin")

