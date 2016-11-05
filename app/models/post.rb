class Post < ActiveRecord::Base
    belongs_to :user
    has_many :comments
    acts_as_taggable_on :tags
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
        
    self.per_page = 10
    
    def update_streak
        if self.user.streak_end
            self.user.touch(:streak_start) unless self.user.streak_end > Time.zone.yesterday.beginning_of_day
        else
            self.user.touch(:streak_start)
        end
        self.user.touch(:streak_end)
    end
    
    def self.search(search, user_id = nil)
        if search
            # 날짜 - 말씀 순서로 검색
            date = search.match('(19|20\d\d)?[- /.년]?\s?([1-9]|0[1-9]|1[012])[- /.월]\s?(0[1-9]|[12][0-9]|3[01]|[1-9])일?\s?')
            book_line = search.match('(([a-zA-Z]{2,}|[가-힣]{2,})\s*(?:(?:[1-9]{1,3}[:장]?)\s?(?:[1-9]{1,3}[절]?)?)?)')
            tag = search.match('\S*#(?:\[[^\]]+\]|\S+)')
            
            if date && date[2] && date[3]
                year = date[1] ? date[1].to_i : Date.current.year
                month = date[2].to_i
                day = date[3].to_i
                result = where("created_at >= ? and created_at <= ?", Date.new(year, month, day).beginning_of_day, Date.new(year, month, day).end_of_day)
                result = result.where(user_id: user_id) if user_id
            elsif tag
                if user_id
                    tagged_with(tag[0], :on => :tags, :owned_by => User.find_by(id: user_id))
                else
                    tagged_with(tag[0], :on => :tags)
                end
            elsif book_line
                full_book_line = book_line[0].downcase.gsub('장', ':').gsub('절', '')
                full_book_line = full_book_line.slice(0,1).capitalize + full_book_line.slice(1..-1)
                short_book_line = book_line[1]
                result = where("title LIKE ?", "%#{full_book_line}%").present? ? where("title LIKE ?", "%#{full_book_line}%") : where("title LIKE ?", "%#{short_book_line}%")
                result = result.where(user_id: user_id) if user_id
            end
        else
            all
        end
    end
end

  
