class AddApplyToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :apply, :string
  end
end
