require 'open-uri'
require 'capybara/poltergeist'

class HomeController < ApplicationController
  before_action :require_login, except: [:index]
  before_action :calculate_exp
  before_action :calculate_achievement
  include ApplicationHelper

  def index
    @is_logged_in = user_signed_in?
    today_posts = Post.where("created_at >= ?", Time.zone.now.beginning_of_day)
    if user_signed_in?
      @today_post = today_posts.find_by user_id: current_user.id
    end
    
    #작성중이던 글이 있으면 불러온다.
    @temp_post = cookies[:post]
    cookies[:post] = nil
    
    data = cookies[:data] ? cookies[:data] : NewQt.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day).to_h
    cookies[:data] = data unless cookies[:data]
    
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
    
 
  end
  
  def write
    
    today_posts = Post.where("created_at >= ?", Time.zone.now.beginning_of_day)
    today_post = today_posts.find_by user_id: current_user.id
    if today_post
      add_to_flash_array :danger, "QT는 하루에 한 번만 가능합니다."
    else
      new_post = Post.new
      new_post.user_id = current_user.id
      new_post.whois = params[:whois]
      new_post.lesson = params[:lesson]
      
      if new_post.save
        now_exp = current_user.now_exp
        new_exp = 30 + Random.rand(50)
        now_talent = current_user.talent
        new_talent = 5 + Random.rand(15)
        current_user.now_exp = now_exp + new_exp
        current_user.talent = now_talent + new_talent
        current_user.save
        add_to_flash_array :success, "저장되었습니다."
        add_to_flash_array :info, "#{new_exp} 경험치와 #{new_talent} 달란트를 획득하였습니다."
      else 
        new_post.errors.each do |attr, error|
          add_to_flash_array :danger, error
          cookies[:post] = [params[:whois], params[:lesson]]
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
      if @one_post.save
        add_to_flash_array :info, "수정되었습니다."
      else
        @one_post.errors.each do |attr, error|
          add_to_flash_array :danger, error
        end
      end
    else
       add_to_flash_array :danger, "유효하지 않은 게시물입니다."
    end
    redirect_to "/"
  end
  
  def profile
    @complete_days = Array.new
    @posts = Post.where(:user_id => current_user.id)
    @post_count = @posts.length
    
    #쿼리가 있으면 쿼리에 해당하는 날짜의 qt를 불러오고, 없으면 오늘 qt를 불러온다.
    if params[:year] && params[:month] && params[:day]
      year = params[:year].to_i
      month = params[:month].to_i
      day = params[:day].to_i
      @date = Date.new(year, month, day)
      @last_month = @date.last_month.month
      @next_month = @date.next_month.month
      @posts_of_this_month = @posts.where(:created_at => @date.beginning_of_month..@date.end_of_month)
      @today_qt = NewQt.new(year, month, day).to_h
      @today_post = @posts.where(:created_at => @date...@date + 1).first
      if @posts_of_this_month.exists?
        @posts_of_this_month.each { |p| @complete_days << p.created_at.day }
      end
      @last_day = Date.civil(year, month, -1).day
      @last_year = @last_month == 12 ? @date.last_year.year : year
      @next_year = @next_month == 1 ? @date.next_year.year : year
    else
      @last_month = Time.current.last_month.month
      @next_month = Time.current.next_month.month
      @posts_of_this_month = @posts.where(:created_at => Time.current.beginning_of_month..Time.current.end_of_month)
      @today_qt = cookies[:data] ? cookies[:data] : NewQt.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day).to_h
      @today_post = @posts.where("created_at >= ?", Time.zone.now.beginning_of_day).first
      if @posts_of_this_month.exists?
        @posts_of_this_month.each { |p| @complete_days << p.created_at.day }
      end
      @last_day = Date.civil(Time.current.year, Time.current.month, -1).day
      @last_year = @last_month == 12 ? Time.current.last_year.year : Time.current.year
      @next_year = @next_month == 1 ? Time.current.next_year.year : Time.current.year
    end
  end
  
  class NewQt
    def initialize(year, month, day)
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
      end
      
      Capybara.default_selector = :xpath
      session = Capybara::Session.new(:poltergeist)
      session.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
      session.visit "http://su.or.kr/03bible/daily/qtView.do?qtType=QT2"
      session.execute_script("document.all['Form'].action = '/03bible/daily/qtView.do'; document.all['Form'].year.value=#{year}; document.all['Form'].month.value=#{month}; document.all['Form'].day.value=#{day}; document.all['Form'].submit(); ")
      sleep 3
      @doc = Nokogiri::HTML.parse(session.html)
    end
    
    def get_title
      @doc.css(".story_view").css(".subject").inner_text
    end
    
    def get_book_line
      @doc.css(".story_view").css(".book_line").inner_text
    end
    
    def get_words
      words = Array.new
      @doc.css(".story_view").css("tr").each do |x|
        words << [x.css("th").inner_text, x.css("td").inner_text]
      end
      words
    end
    
    def get_info
      info = @doc.css(".detail_info").children.map do |t|
        t.text.strip
      end
      info.delete("")
      last_index = info.index("적용하기")
      info1 = info[1..last_index-1]
      
      first_index = info.index("하나님은 어떤 분입니까?") ? info.index("하나님은 어떤 분입니까?")+1 : false
      info2 = first_index ? info[first_index] : "오늘은 해설이 없습니다."
      
      first_index = info.index("내게 주시는 교훈은 무엇입니까?") ? info.index("내게 주시는 교훈은 무엇입니까?")+1 : false
      info3 = first_index ? info[first_index] : "오늘은 해설이 없습니다."
      result = {
        :explanation => info1,
        :whois => info2,
        :lesson => info3
      }
    end
    
    def to_h
      info = get_info
      data = {
        :title => get_title,
        :book_line => get_book_line,
        :words => get_words,
        :explanation => info[:explanation],
        :whois => info[:whois],
        :lesson => info[:lesson],
        :created_at => Time.zone.now
      }
    end
  end
  
end
