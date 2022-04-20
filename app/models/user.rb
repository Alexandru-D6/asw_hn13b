class User < ApplicationRecord
  serialize :LikedSubmissions
  serialize :LikedComments

  after_initialize do |user|
    user.LikedSubmissions= [] if user.LikedSubmissions == nil
    user.LikedComments= [] if user.LikedComments == nil
  end
  

  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:github]
  
  def self.from_omniauth(access_token)
    data = access_token.info
    @user = User.where(email: data["email"]).first

    unless @user
      @user = User.create(
        email: data["email"],
        password: Devise.friendly_token[0, 20]
      )
      
      @user.name = access_token.info.nickname
      @user.provider = access_token.provider
      @user.uid = access_token.uid
      @user.save
      
      logger.debug "#{data}"
    end
    
    @user
  end
  
end
