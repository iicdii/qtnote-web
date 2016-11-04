module ApplicationHelper
  
  def add_to_flash_array key, value, options={}, settings={}
    # set empty array as default value
    flash[key] ||= [] 
    flash[key] << [value, options, settings] if flash[key].is_a? Array
  end
  
  def get_achievements
    [
      {id: 1, title: t("text.achievements.sign_in_x_times", number: 3), description: t("text.achievements.sign_in_x_times_description", number: 3)},
      {id: 2, title: t("text.achievements.level_x", level: 5), description: t("text.achievements.level_x_description", level: 5)},
      {id: 3, title: t("text.achievements.level_x", level: 50), description: t("text.achievements.level_x_description", level: 50)},
      {id: 4, title: t("text.achievements.level_x", level: 99), description: t("text.achievements.level_x_description", level: 99)},
      {id: 5, title: t("text.achievements.x_days_streak", days: 7), description: t("text.achievements.x_days_streak_description", days: 7)},
      {id: 6, title: t("text.achievements.millionaire", talent: 10000), description: t("text.achievements.millionaire_description", talent: 10000)}
    ]
  end
  
  def display_name(user_id)
    user = User.find_by id: user_id
    if user
      user.nickname ? user.nickname : user.email.split("@")[0]
    else
      t 'text.ghost'
    end
  end
  
  def display_level user_id
    user = User.find_by id: user_id
    if user
      user.level
    else
      0
    end
  end
  
  def get_user user_id
    user = User.find_by id: user_id
    user
  end
  
  def get_user_name user_id
    user = User.find_by id: user_id
    if user
      if user.nickname
        '@' + user.nickname
      else
        user.id
      end
    else
      0
    end
  end
  
  def auto_link_usernames(text)
    text.gsub /@([가-힣]+|\w+)/ do |username|
      name = username.gsub('@', '')
      if User.where("email like ?", "%#{name}%").present?
        id = User.where("email like ?", "%#{name}%").first.id
      elsif User.where("nickname like ?", "%#{name}%").present?
        id = '@' + User.where("nickname like ?", "%#{name}%").first.nickname
      end
      id ? link_to(username, user_path(id)) : username
    end.html_safe
  end
  
  # Below methods are Devise helper
  
  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  
end
