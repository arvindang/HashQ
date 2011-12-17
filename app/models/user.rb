class User < ActiveRecord::Base
  
  after_create :save_twitter_id 
  
  has_many  :oauth1
  
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and 
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  attr_accessor :twitter_id  # we define this to assist with passing the new_with_session params
      
  # model's can not get session values, therefore super helpes pass the value  
  def self.new_with_session(params, session)
        model = super(params,session)          
        model.twitter_id = session["devise.twitter_id"]
        model
    end
  
  # find the oauth record and assign the user_id to it
  def save_twitter_id
    oauth1=Oauth.find_by_uid(self.twitter_id)
    oauth1.update_attributes(:user_id => self.id)
  end
  
end
