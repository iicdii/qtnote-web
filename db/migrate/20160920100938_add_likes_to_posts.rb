class AddLikesToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :likes, :integer, array: true, default: []
  end
end
