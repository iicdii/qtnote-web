class Users::ProfileController < ApplicationController
    include ApplicationHelper
    
    def index
        @user = User.find_by id: params[:id]
        if @user
            @achievements = Array.new
            achievements = get_achievements
            achievements.each do |a|
              achievement = @user.achievements.find {|h| h[:id] == a[:id] }
              @achievements << {
                :id => a[:id],
                :title => a[:title],
                :description => a[:description],
                :is_active => achievement ? true : false,
                :created_at => achievement ? achievement[:created_at] : ""
              }
            end
        end
    end
end