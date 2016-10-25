class CommentsController < ApplicationController
  def index
  end
  
  def fetch type, id
    if type == 'post'
      @post = Post.find_by id: id
      render partial: 'comments/comments_list', locals: { comments: @post.comments.where(parent_id: nil) }
    elsif type == 'comment'
      @comment = Comment.find_by id: id
      render partial: 'comments/comment', locals: { comment: @comment }
    end
  end
  
  def write
    if params[:type] == 'post'
      post = Post.find_by id: params[:id]
      body = params[:body]
      comment = Comment.create(post_id: post.id, user_id: current_user.id, body: body)
      if post.user_id != current_user.id && User.find_by(id: post.user_id).present?
        Message.create(
          user_id: User.find_by(id: post.user_id).id,
          sender_id: current_user.id,
          activity_type: 2,
          object_type: 'post',
          object_id: comment.id
        )
      end
      fetch(params[:type], post.id)
    elsif params[:type] == 'comment'
      comment = Comment.find_by id: params[:parent_id]
      body = params[:body]
      Comment.create(parent_id: params[:parent_id], post_id: comment.post_id, user_id: current_user.id, body: body)
      if comment.user_id != current_user.id && User.find_by(id: comment.user_id).present?
        Message.create(
          user_id: User.find_by(id: comment.user_id).id,
          sender_id: current_user.id,
          activity_type: 2,
          object_type: 'comment',
          object_id: comment.id
        )
      end
      fetch(params[:type], comment.id)
    end
  end
  
  def modify
    comment = Comment.find_by id: params[:id]
    if request.xhr? && comment.user_id == current_user.id
      comment.update_attributes(body: params[:body])
      comment.save!
      render json: { id: params[:id] }
    end
  end
  
  def delete
    comment = Comment.find_by id: params[:id]
    if request.xhr? && comment.user_id == current_user.id
      message = Message.find_by(sender_id: current_user.id, activity_type: 2, object_id: comment.id)
      message.destroy!
      comment.destroy!
    end
  end
  
  def like
    @comment = Comment.find_by id: params[:id]
    if request.xhr?
      if @comment
        unless @comment.likes.include?(current_user.id)
          # like
          @comment.likes = Array.new unless @comment.likes.is_a?(Array) 
          @comment.likes << current_user.id
          @comment.save!
          if !Message.find_by(
            user_id: User.find_by(id: @comment.user_id).id,
            sender_id: current_user.id,
            activity_type: 1,
            object_type: 'comment',
            object_id: params[:id]
          ).present? && @comment.user_id != current_user.id && User.find_by(id: @comment.user_id).present?
            Message.create(
              user_id: User.find_by(id: @comment.user_id).id,
              sender_id: current_user.id,
              activity_type: 1,
              object_type: 'comment',
              object_id: params[:id]
            )
          end
          render json: { actionType: 'like', count: @comment.likes.length, id: params[:id] }
        else
          # dislike
          if @comment.likes.is_a?(Array) 
            @comment.likes.delete(current_user.id)
          end
          @comment.save!
          render json: { actionType: 'dislike', count: @comment.likes.length, id: params[:id] }
        end
      end
    end
  end
end
