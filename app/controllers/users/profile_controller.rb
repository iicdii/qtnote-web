class Users::ProfileController < ApplicationController
    include ApplicationHelper
    
    def index
        @user = User.find_by id: params[:id]
        if @user
            @number_of_qt_this_month = @user.posts.where("created_at >= ? and created_at <= ?", Time.current.beginning_of_month, Time.current.end_of_month).count
            @number_of_qt_this_week = @user.posts.where("created_at >= ? and created_at <= ?", Time.current.beginning_of_week, Time.current.end_of_week).count
            
            #sum = 0
            #@user.posts.last(5).each do |p|
            #  sum += (p.created_at).to_i
            #end
            #@usual_time_for_qt = Time.at(sum / @user.posts.count)
            #
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