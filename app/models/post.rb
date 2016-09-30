class Post < ActiveRecord::Base
    belongs_to :user
    has_many :comments
    after_create :update_streak
    
    default_scope { order('created_at DESC') }
    
    validates :whois,
        presence: true,
        length: {
            minimum: 5,
            maximum: 300
        }
    validates :lesson,
        presence: true,
        length: {
            minimum: 10,
            maximum: 1000
        }
    validates :apply,
        presence: true,
        length: {
            minimum: 5,
            maximum: 1000
        }
    
    def update_streak
        if self.user.streak_end
            self.user.touch(:streak_start) unless self.user.streak_end > Time.zone.yesterday.beginning_of_day
        else
            self.user.touch(:streak_start)
        end
        self.user.touch(:streak_end)
    end
end

  
