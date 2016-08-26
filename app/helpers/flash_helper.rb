module FlashHelper
  
  def add_to_flash_array key, value, options={}, settings={}
    # set empty array as default value
    flash[key] ||= [] 
    flash[key] << [value, options, settings]
  end
  
end
