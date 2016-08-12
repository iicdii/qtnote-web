class Post < ActiveRecord::Base
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
end
