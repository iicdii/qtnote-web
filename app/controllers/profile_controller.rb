class ProfileController < ApplicationController
  before_action :require_login
  include ApplicationHelper
  include FlashHelper
  include QtHelper
  def index
    @complete_days = Array.new
    @achievements = Array.new
    @posts = current_user.posts
    @post_count = @posts.length
    @number_of_qt_this_month = @posts.where("created_at >= ? and created_at <= ?", Time.current.beginning_of_month, Time.current.end_of_month).count
    @number_of_qt_this_week = @posts.where("created_at >= ? and created_at <= ?", Time.current.beginning_of_week, Time.current.end_of_week).count
    # sum = 0
    # current_user.posts.last(5).each do |p|
    #   sum += (p.created_at).to_i
    # end
    # @usual_time_for_qt = Time.at(sum / current_user.posts.count)
    
    # 쿼리가 있으면 쿼리에 해당하는 날짜의 post를 불러오고, 없으면 오늘 post를 불러온다.
    if params[:year] && params[:month] && params[:day]
      year = params[:year].to_i
      month = params[:month].to_i
      day = params[:day].to_i
      @date = Date.new(year, month, day)
      @last_month = @date.last_month.month
      @next_month = @date.next_month.month
      @posts_of_this_month = @posts.where('extract(month from created_at) = ?', @date.month) 
      @today_qt = NewQt.new(year, month, day).to_h
      @today_post = @posts.where(:created_at => @date.beginning_of_day...@date.end_of_day).first
      @posts_of_this_month.each { |p| @complete_days << p.created_at.day } if @posts_of_this_month.exists?
      @last_day = Date.civil(year, month, -1).day
      @last_year = @last_month == 12 ? @date.last_year.year : year
      @next_year = @next_month == 1 ? @date.next_year.year : year
    else
      @last_month = Time.current.last_month.month
      @next_month = Time.current.next_month.month
      @posts_of_this_month = @posts.where('extract(month from created_at) = ?', Time.current.month)
      @today_qt = NewQt.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day).to_h
      @today_post = @posts.where("created_at >= ?", Time.zone.now.beginning_of_day).first
      @posts_of_this_month.each { |p| @complete_days << p.created_at.day } if @posts_of_this_month.exists?
      @last_day = Date.civil(Time.current.year, Time.current.month, -1).day
      @last_year = @last_month == 12 ? Time.current.last_year.year : Time.current.year
      @next_year = @next_month == 1 ? Time.current.next_year.year : Time.current.year
    end
    
    # 태그 불러오기
    if @today_post
      tags = @today_post.owner_tags_on(current_user, :tags)
      if tags.present?
        @tags = Array.new
        tags.each do |t|
          @tags << t.name
        end
      end
    end
    
    # 업적을 불러온다.
    achievements = get_achievements
    achievements.each do |a|
      achievement = current_user.achievements.find {|h| h[:id] == a[:id] }
      @achievements << {
        :id => a[:id],
        :title => a[:title],
        :description => a[:description],
        :is_active => achievement ? true : false,
        :created_at => achievement ? achievement[:created_at] : ""
      }
    end
    
    # 목록형 QT 페이지네이트
    current_page = params[:page] ? params[:page] : 1
    @listed_post = @posts.paginate(:page => current_page, :per_page => 10)
  end
end
