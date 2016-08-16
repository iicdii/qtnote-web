class AddPrayToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :pray, :string
    Post.all.each do |post|
      post.update_attributes!(:pray => '')
    end
  end
end
