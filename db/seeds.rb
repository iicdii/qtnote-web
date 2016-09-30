# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
50.times { |i| Post.create(whois: "Post #{i}", lesson: BetterLorem.p(10, true, true), apply: BetterLorem.c(20), is_public: true, user_id: 2) }