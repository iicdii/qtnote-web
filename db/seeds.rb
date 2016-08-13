# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

achievements = [
    {title: "세 번 접속", description: "3번 로그인"},
    {title: "레벨 5 달성", description: "5레벨 달성"},
    {title: "레벨 50 달성", description: "50레벨 달성"},
    {title: "레벨 99 달성", description: "99레벨 달성"}
    ]
achievements.each do |attrs|
    Achievement.create(attrs) unless Achievement.where(attrs).first
end
