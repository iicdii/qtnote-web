module ApplicationHelper
  
  def add_to_flash_array key, value, options={}, settings={}
    # set empty array as default value
    flash[key] ||= [] 
    flash[key] << [value, options, settings]
  end
  
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
