class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  before_action :set_locale
  before_action :calculate_exp
  before_action :calculate_achievement
  before_action :get_messages
  before_action :remove_cookies
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  include ApplicationHelper
  
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  def self.default_url_options
    { locale: I18n.locale }
  end
  
  def require_login
    unless user_signed_in?
      redirect_to new_user_session_url
    end
  end
  
  def get_messages
    if user_signed_in?
      @messages = current_user.messages.where(is_read:false).order(created_at: :desc)
    end
  end
  
  def calculate_exp
    # 다음 경험치 계산
    unless @next_exps
      @next_exps = Array.new
      for i in 0..99
         @next_exps.push(50 + (i * 7))
      end
    end
    if user_signed_in?
      # 레벨업
      if current_user.now_exp/@next_exps[current_user.level-1] >= 1
        current_user.now_exp = current_user.now_exp - @next_exps[current_user.level-1]
        current_user.level = current_user.level + 1
        current_user.save
        flash.now[:info] = t 'text.level_up'
        @leveled_up = true
      end
    end
  end
  
  def notify(id, title)
    add_to_flash_array :info, title,
    {
      icon: ActionController::Base.helpers.image_path('achievement_' + id.to_s + '.png'),
      title: '<strong>' + t("text.new_achievement") + '</strong>',
      url: I18n.locale == :en ? '/en/profile?type=achievement' : '/profile?type=achievement',
      target: "_self"
    },
    {
      animate: {enter: 'animated bounceIn', exit: 'animated bounceOut' },
      icon_type: 'image'
    }
  end
  
  def calculate_achievement
    if user_signed_in?
      # 연속 QT일 계산
      @streak_days = current_user.streak_start && current_user.streak_end && current_user.streak_end > Time.zone.yesterday.beginning_of_day ? (current_user.streak_end.to_date - current_user.streak_start.to_date).to_i + 1  : 0
      if @streak_days >= current_user.max_streak_days
        current_user.max_streak_days = @streak_days if @streak_days >= current_user.max_streak_days
        current_user.save
      end
      
      achievements = get_achievements
      
      (1..6).each do |id|
        if current_user.achievements.any? { |a| a[:id] == id } == false
          case id
          when 1 # 3번 접속 달성시
            if current_user.sign_in_count_per_day >= 3
              current_user.achievements << {id: id, created_at: Time.current} 
              notify(id, achievements.find{|h| h[:id] == id }[:title])
            end
          when 2 # 5레벨 달성시
            if current_user.level >= 5
              current_user.achievements << {id: id, created_at: Time.current} 
              notify(id, achievements.find{|h| h[:id] == id }[:title])
            end
          when 3 # 50레벨 달성시
            if current_user.level >= 50
              current_user.achievements << {id: id, created_at: Time.current} 
              notify(id, achievements.find{|h| h[:id] == id }[:title])
            end
          when 4 # 99레벨 달성시
            if current_user.level >= 99
              current_user.achievements << {id: id, created_at: Time.current} 
              notify(id, achievements.find{|h| h[:id] == id }[:title])
            end
          when 5 # 7일 연속 QT 달성시
            if @streak_days >= 7
              current_user.achievements << {id: id, created_at: Time.current} 
              notify(id, achievements.find{|h| h[:id] == id }[:title])
            end
          when 6 # 10,000달란트 달성시
            if current_user.talent >= 10000
              current_user.achievements << {id: id, created_at: Time.current}
              notify(id, achievements.find{|h| h[:id] == id }[:title])
            end
          else
          end
          current_user.save
        end
      end
    end
  end
  
  def remove_cookies
    
    if cookies[:done]
      data = Hash.new
      data = ActiveSupport::JSON.decode(cookies[:done])
      if data['is_showed'] == true
        cookies.delete(:done)
      else
        cookies[:done] = ActiveSupport::JSON.encode({
          exp: data['exp'], talent: data['talent'], is_showed: true, is_public: data['is_public']
        })
      end
    end
  end
  
  after_filter :store_location
  before_filter :store_current_location, :unless => :devise_controller?
  
  private
  
  # override the devise helper to store the current location so we can
  # redirect to it after loggin in or out. This override makes signing in
  # and signing up work automatically.
  def after_sign_in_path_for(resource)
    
    # redirect to the form if there is a post data in the session
    if session[:post].present?
      @post = session[:post]
    end
    session[:previous_url] || root_path
  end
  
  def after_sign_out_path_for(resource_or_scope)
    request.referrer || root_path
  end
  
  def after_update_path_for(resource)
    session[:previous_url] || root_path
  end
  
  def store_current_location
    store_location_for(:user, request.url)
  end
  
  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? 
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
        if request.format == "text/html" || request.content_type == "text/html"
          session[:previous_url] = request.fullpath
          session[:last_request_time] = Time.now.utc.to_i
        end
    end
  end
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname])
  end

end
