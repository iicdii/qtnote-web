class ChangeStringToTextInPost < ActiveRecord::Migration
  def self.up
    change_table :posts do |t|
      t.change :whois, :text
      t.change :lesson, :text
      t.change :apply, :text
      t.change :pray, :text
    end
  end

  def self.down
    change_table :posts do |t|
      t.change :whois, :string
      t.change :lesson, :string
      t.change :apply, :string
      t.change :pray, :string
    end
  end
end
