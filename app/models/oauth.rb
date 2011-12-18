class Oauth < ActiveRecord::Base

  belongs_to              :user

  def self.find_or_create_twitter(access_token)
    data = access_token
    
    oauth=Oauth.find_by_uid(data.uid)
    if oauth
      oauth
    else 
      if data.uid
        oauth = Oauth.create(hashit(data))
      end
    end
  end
  
  def sign_in 
    Twitter.configure do |config|
      config.oauth_token = self.oauth_token
      config.oauth_token_secret = self.oauth_secret
    end
  end
  
  
  def self.hashit(omniauth)
          data =   {
                        :provider     => omniauth.provider,
                        :uid          => omniauth.uid,
                        :name         => omniauth.info.name,
                        :email        => omniauth.info.email,
                        :nickname     => omniauth.info.nickname,
                        :first_name   => omniauth.info.first_name,
                        :last_name    => omniauth.info.last_name,
                        :location     => omniauth.info.location,
                        :description  => omniauth.info.description,
                        :image        => omniauth.info.image,
                        :phone        => omniauth.info.phone,
                        :urls         => omniauth.info.urls,
                        :oauth_token  => omniauth.credentials.token,
                        :oauth_secret => omniauth.credentials.secret,
                        :extra        => omniauth.extra
                        # :user_id    => nil
                      }
  end
  
end
