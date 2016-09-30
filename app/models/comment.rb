class Comment < ActiveRecord::Base
    belongs_to :post
    belongs_to :parent,  class_name: "Comment" #-> requires "parent_id" column
    has_many   :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
    
    default_scope { order('created_at DESC') }
    
    validates :body,
        length: {
            minimum: 1,
            maximum: 300
        }
end
