class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.integer :sender_id
      t.integer :activity_type 
      t.integer :object_id
      t.string :object_type
      t.boolean :is_read, default: false

      t.timestamps null: false
    end
  end
end
