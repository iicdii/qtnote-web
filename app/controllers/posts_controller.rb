class PostsController < ApplicationController
  before_action :require_login, only: [:like, :dislike]
  
  def index
    if user_signed_in? && current_user.id == Post.find_by(id: params[:id]).user_id
      @post = Post.find_by(id: params[:id])
    else
      @post = Post.find_by(id: params[:id], is_public: true)
    end
  end
  
  def fetch
    if request.xhr?
      if params[:type] == 'posts'
        the_day_at = Time.current.change(year: params[:year].to_i, month: params[:month].to_i, day: params[:day].to_i)
        @selected = Post.where("created_at >= ? and created_at <= ? and is_public = ?", the_day_at.beginning_of_day, the_day_at.end_of_day, true).order(created_at: :desc).limit(7)
        render :partial => 'posts/posts_list', locals: {posts: @selected}
      elsif params[:type] == 'post'
        if params[:id]
          @post = Post.find_by id: params[:id]
          render :partial => 'posts/post', locals: {post: @post}
        end
      elsif params[:type] == 'days'
        year = params[:year].to_i
        month = params[:month].to_i
        day = params[:day].to_i
        start_day = Date.new(year, month, day).beginning_of_week
        end_day = Date.new(year, month, day).end_of_week
        @days = Array.new
        start_day.upto(end_day) do |d|
          @days << d.strftime("%y/%m/%d")
        end
        render :partial => 'posts/days_list', locals: {days: @days, year: year, month: month, day: day}
      end
    else
      head 404
    end
  end
  
  def like
    @post = Post.find_by id: params[:id]
    if request.xhr?
      if @post
        unless @post.likes.include?(current_user.id)
          # like
          @post.likes = Array.new unless @post.likes.is_a?(Array)
          @post.likes << current_user.id
          @post.save!
            if !Message.find_by(
              user_id: User.find_by(id: @post.user_id).id,
              sender_id: current_user.id,
              activity_type: 1,
              object_type: 'post',
              object_id: params[:id]
            ).present? && @post.user_id != current_user.id
              Message.create(
                user_id: User.find_by(id: @post.user_id).id,
                sender_id: current_user.id,
                activity_type: 1,
                object_type: 'post',
                object_id: params[:id]
              )
            end
          render json: { actionType: 'like', count: @post.likes.length, id: params[:id] }
        else
          # dislike
          @post.likes.delete(current_user.id) if @post.likes.is_a?(Array)
          @post.save!
          render json: { actionType: 'dislike', count: @post.likes.length, id: params[:id] }
        end
      end
    end
  end
end
