class PostsController < ApplicationController
  before_action :require_login, only: [:like, :dislike]
  
  def index
    if current_user.id == params[:id]
      @post = Post.find_by(id: params[:id])
    else
      @post = Post.find_by(id: params[:id], is_public: true)
    end
  end
  
  def like
    @post = Post.find_by id: params[:id]
    if request.xhr?
      if @post
        unless @post.likes.include?(current_user.id)
          if @post.likes.is_a?(Array) 
            @post.likes << current_user.id
          else
            @post.likes = Array.new
            @post.likes << current_user.id
          end
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
          render json: { count: @post.likes.length, id: params[:id] }
        else
          head :ok
        end
      else
        head 404
      end
    else
      head 404
    end
  end
  
  def dislike
    @post = Post.find_by id: params[:id]
    if request.xhr?
      if @post
        if @post.likes.include?(current_user.id)
          if @post.likes.is_a?(Array) 
            @post.likes.delete(current_user.id)
          end
          @post.save!
          render json: { count: @post.likes.length, id: params[:id] }
        else
          head :ok
        end
      else
        head 404
      end
    else
      head 404
    end
  end
end
