class AddApplyToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :apply, :string
    Post.all.each do |post|
      post.update_attributes!(:apply => '')
    end
  end
end
