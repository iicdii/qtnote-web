# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#   50.times { |i| Post.create(whois: "Post #{i}", lesson: BetterLorem.p(10, true, true), apply: BetterLorem.c(20), is_public: true, user_id: 2) }
require 'open-uri'

Post.where(title: nil).each do |p|
    year = p.created_at.year
    month = p.created_at.month
    day = p.created_at.day
    doc = Nokogiri::HTML(open("http://su.or.kr/03bible/daily/qtView.do?qtType=QT2&year=#{year}&month=#{month}&day=#{day}"))
    book_line = doc.css(".story_view").css(".book_line").inner_text
    post_title = book_line.match('\[(.*?)\]')[0].gsub('[', '').gsub(']', '')
    p.update_attributes!(title: post_title)
end