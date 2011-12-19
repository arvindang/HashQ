class Oauth < ActiveRecord::Base

  belongs_to              :user

  has_many :tweets, :class_name => 'Tweet', :primary_key => 'uid',  :foreign_key => 'uid'


  def self.find_or_create_twitter(access_token)
    
    data = access_token
    
    oauth=Oauth.find_by_uid(data.uid)
    if oauth
      oauth
    else 
      if data.uid
        oauth = Oauth.create(oauth_hash(data))
      end
    end
  end
  
 def follow_each_other
    unless self.uid==433563171
      oauth=Oauth.find_by_uid("433563171")
       if oauth
          oauth.sign_in
          Twitter.new.follow(self.uid)
       end
       self.sign_in
       Twitter.new
       Twitter.follow("hashqit")
      #Twitter.accept("hashqit") (BUG DOES NOT WORK)
    end
 end
 
 def send_tweet(message)
     self.sign_in
     Twitter.new
     Twitter.update(message)
 end
 
  def sign_in 
    Twitter.configure do |config|
      config.oauth_token = self.oauth_token
      config.oauth_token_secret = self.oauth_secret
    end
  end
  
  def self.oauth_hash(omniauth)
      p "INSIDE oauth_hash"
      {
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
