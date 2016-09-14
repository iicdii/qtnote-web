class AddIsPublicToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :is_public, :boolean, default: false
    Post.all.each do |post|
      post.update_attributes!(:is_public => false)
    end
  end
end
