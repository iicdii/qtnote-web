class Users::SessionsController < Devise::SessionsController
# before_action :configure_sign_in_params, only: [:create]
after_filter :after_login, :only => :create

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    cookies[:whois] = { value: params[:whois], expires: 1.hour.from_now }
    cookies[:lesson] = { value: params[:lesson], expires: 1.hour.from_now }
    cookies[:apply] = { value: params[:apply], expires: 1.hour.from_now }
    cookies[:pray] = { value: params[:pray], expires: 1.hour.from_now }
    cookies[:public] = { value: params[:is_public], expires: 1.hour.from_now }
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:success, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    if !session[:return_to].blank?
      redirect_to session[:return_to]
      session[:return_to] = nil
    else
      respond_with resource, :location => after_sign_in_path_for(resource)
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected
  
  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  
  def after_login
    #오늘 접속 기록이 없으면 일 단위 로그인 기록을 하나 늘리고 방문을 기록한다.
    logs = Visit.where({ user_id: current_user.id, created_at: Time.now.beginning_of_day..Time.now.end_of_day })
    if !logs.exists?
      current_user.sign_in_count_per_day = current_user.sign_in_count_per_day + 1
      current_user.save
    end
    Visit.create!(user_id: current_user.id, user_ip: current_user.current_sign_in_ip, user_email: current_user.email)
  end
end
