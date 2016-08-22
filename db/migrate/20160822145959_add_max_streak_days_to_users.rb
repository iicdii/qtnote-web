class AddMaxStreakDaysToUsers < ActiveRecord::Migration
  def change
    add_column :users, :max_streak_days, :integer, :default => 0
    User.all.each do |user|
      user.update_attributes!(:max_streak_days => 0)
    end
  end
end
