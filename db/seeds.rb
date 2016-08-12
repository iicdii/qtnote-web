# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

achievements = [
    {title: "3번 접속", description: "3번 로그인"}
    ]
achievements.each do |attrs|
    Achievement.create(attrs) unless Achievement.where(attrs).first
end
