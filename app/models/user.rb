class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable
         
  def self.from_omniauth(auth)
    
    data = auth.info
    user = User.where(email: data['email'])
    
    unless user
      user = User.create(
        provider: data['provider'],
        name: data['name'],
        username: data['nickname'],
        uid: data['uid'],
        email: data['email'],
        password: Devise.friendly_token[0,20]
        )
    end
    
    
    
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user |
      user.provider = auth.provider
      user.name = auth.info.name
      user.username = auth.info.nickname
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end
  end
  
end
