class Oauth < ActiveRecord::Base

  belongs_to              :user

  def self.find_or_create_twitter(access_token)
    data = access_token
    oauth=Oauth.find_by_uid(data.uid)
    if oauth
      oauth
    else 
      if data.uid
        oauth = Oauth.create(:uid => data.uid, :provider => 'twitter')
      end
    end
  end
end
