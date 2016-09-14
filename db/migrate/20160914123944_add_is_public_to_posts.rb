class AddIsPublicToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :is_public, :boolean, default: false
  end
end
