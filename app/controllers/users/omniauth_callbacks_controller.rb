class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  def facebook
    handle_redirect('devise.facebook_data', 'Facebook')
  end

  def google_oauth2
    handle_redirect('devise.google_data', 'Google')
  end
  
  def handle_redirect(_session_variable, kind)
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    I18n.locale = session[:omniauth_login_locale] || I18n.default_locale

    if @user.persisted?
      flash[:success] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
      sign_in_and_redirect @user, :event => :authentication
    else
      session[_session_variable] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
  
  def failure
    redirect_to root_path
  end
  
  def user
    User.find_for_oauth(env['omniauth.auth'], current_user)
  end

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
