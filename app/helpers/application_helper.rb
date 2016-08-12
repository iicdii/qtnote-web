module ApplicationHelper
  
  def add_to_flash_array key, value
    # set empty array as default value
    flash[key] ||= [] 

    if flash[key].is_a? Array
      flash[key] << value
    else # somebody set a value from underneath this method, enter panic mode
      raise "flash['#{key}'] is not an array!"
    end
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
