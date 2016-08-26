class User < ActiveRecord::Base
  has_many :posts
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]
  serialize :achievements, Array
  
  def self.from_omniauth(access_token)
      data = access_token.info
      user = User.where(:email => data["email"]).first
  
      # Uncomment the section below if you want users to be created if they don't exist
      unless user
        user = User.create(
          email: data["email"],
          password: Devise.friendly_token[0,20],
          uid: access_token.uid,
          provider: access_token.provider
        )
      end
      user.skip_confirmation!
      user
  end
end
