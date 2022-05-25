class User < ApplicationRecord
  #serialize :LikedSubmissions
  #serialize :LikedComments
  ##has_secure_token
  ##has_secure_token :auth_token
  
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
      @user.auth_token = Digest::SHA1.hexdigest("#{@user.email}")
      @user.LikedComments = ["{-1}"]
      @user.LikedSubmissions = ["{-1}"]
      @user.save
      
    end
    
    @user
  end
  
end
