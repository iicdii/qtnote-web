class Post < ActiveRecord::Base
    belongs_to :user
    after_create :update_streak
    
    
    validates :whois,
        presence: { message: "내용을 입력해 주세요." },
        length: {
            minimum: 5,
            maximum: 300,
            too_short: "%{count}자 이상 입력해 주세요.",
            too_long: "%{count}자 까지만 입력할 수 있습니다."
        }
    validates :lesson,
        presence: { message: "내용을 입력해 주세요." },
        length: {
            minimum: 10,
            maximum: 1000,
            too_short: "%{count}자 이상 입력해 주세요.",
            too_long: "%{count}자 까지만 입력할 수 있습니다."
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

  
