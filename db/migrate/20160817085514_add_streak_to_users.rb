class AddStreakToUsers < ActiveRecord::Migration
  def change
    add_column :users, :streak_start, :timestamp
    add_column :users, :streak_end, :timestamp
  end
end
