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
