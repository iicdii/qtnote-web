require 'open-uri'

class HomeController < ApplicationController
  before_action :require_login, except: [:index]
  before_action :calculate_exp
  before_action :calculate_achievement
  before_action :remove_cookies, except: [:write]
  include ApplicationHelper
  include FlashHelper
  include QtHelper

  def index
    @is_logged_in = user_signed_in?
    today_posts = Post.where("created_at >= ?", Time.zone.now.beginning_of_day)
    if user_signed_in?
      @today_post = today_posts.find_by user_id: current_user.id
    end
    
    #작성중이던 글이 있으면 불러온다.
    if session[:post]
      @temp_post = session[:post]
      session[:post] = nil
    end
    
    data = NewQt.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day).to_h
    
    #본문 제목 가져오기
    @title = data[:title]
    
    #본문 말씀 가져오기
    @words = data[:words]
    
    #본문 가져오기
    @book_line = data[:book_line]
    
    #본문 해설 가져오기
    @info1 = data[:explanation]
    @info2 = data[:whois]
    @info3 = data[:lesson]
    
    #쿠키 데이터 가져오기
    if cookies[:done]
      @done_data = Hash.new
      @done_data = ActiveSupport::JSON.decode(cookies[:done])
    end
  end
  
  def write
    today_posts = Post.where("created_at >= ?", Time.zone.now.beginning_of_day)
    today_post = today_posts.find_by user_id: current_user.id
    if today_post
      add_to_flash_array :warning, "QT는 하루에 한 번만 가능합니다."
    else
      new_post = Post.new
      new_post.user_id = current_user.id
      new_post.whois = params[:whois]
      new_post.lesson = params[:lesson]
      new_post.apply = params[:apply]
      new_post.pray = params[:pray]
      
      if new_post.save
        now_exp = current_user.now_exp
        new_exp = 30 + Random.rand(30)
        new_exp -= new_exp % 5
        
        now_talent = current_user.talent
        new_talent = 5 + Random.rand(18)
        new_talent -= new_talent % 5
        
        current_user.now_exp = now_exp + new_exp
        current_user.talent = now_talent + new_talent
        current_user.save
        cookies[:done] = ActiveSupport::JSON.encode({exp: new_exp, talent: new_talent, is_showed: false})
      else 
        new_post.errors.each do |attr, error|
          add_to_flash_array :danger, error
          session[:post] = [params[:whois], params[:lesson], params[:apply], params[:pray]]
        end
      end
    end
    
    redirect_to "/"
  end
  
  def modify
    @one_post = Post.find(params[:id])
    if @one_post
      @one_post.whois = params[:whois]
      @one_post.lesson = params[:lesson]
      @one_post.apply = params[:apply]
      @one_post.pray = params[:pray]
      if @one_post.save
        add_to_flash_array :info, "수정되었습니다."
      else
        @one_post.errors.each do |attr, error|
          add_to_flash_array :danger, error
        end
      end
    else
       add_to_flash_array :warning, "유효하지 않은 게시물입니다."
    end
    redirect_to "/"
  end
  
  def profile
    @complete_days = Array.new
    @achievements = Array.new
    @posts = current_user.posts
    @post_count = @posts.length

    #쿼리가 있으면 쿼리에 해당하는 날짜의 post를 불러오고, 없으면 오늘 post를 불러온다.
    if params[:year] && params[:month] && params[:day]
      year = params[:year].to_i
      month = params[:month].to_i
      day = params[:day].to_i
      @date = Date.new(year, month, day)
      @last_month = @date.last_month.month
      @next_month = @date.next_month.month
      @posts_of_this_month = @posts.where("cast(strftime('%Y', created_at) as int) = ?", @date.month).order("created_at DESC")   
      @today_qt = NewQt.new(year, month, day).to_h
      @today_post = @posts.where(:created_at => @date.beginning_of_day...@date.end_of_day).first
      @posts_of_this_month.each { |p| @complete_days << p.created_at.day } if @posts_of_this_month.exists?
      @last_day = Date.civil(year, month, -1).day
      @last_year = @last_month == 12 ? @date.last_year.year : year
      @next_year = @next_month == 1 ? @date.next_year.year : year
    else
      @last_month = Time.current.last_month.month
      @next_month = Time.current.next_month.month
      @posts_of_this_month = @posts.where("cast(strftime('%Y', created_at) as int) = ?", Time.current.month).order("created_at DESC")
      @today_qt = NewQt.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day).to_h
      @today_post = @posts.where("created_at >= ?", Time.zone.now.beginning_of_day).first
      @posts_of_this_month.each { |p| @complete_days << p.created_at.day } if @posts_of_this_month.exists?
      @last_day = Date.civil(Time.current.year, Time.current.month, -1).day
      @last_year = @last_month == 12 ? Time.current.last_year.year : Time.current.year
      @next_year = @next_month == 1 ? Time.current.next_year.year : Time.current.year
    end
    
    #업적을 불러온다.
    Achievement.all.each do |a|
      achievement = current_user.achievements.find {|h| h[:id] == a.id }
      @achievements << {
        :id => a.id,
        :title => a.title,
        :description => a.description,
        :is_active => achievement ? true : false,
        :created_at => achievement ? achievement[:created_at] : a.created_at
      }
    end
    
  end
  
end
