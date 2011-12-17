class Users::RegistrationsController < Devise::RegistrationsController

  before_filter :oautherized, :only => :new  

  def oautherized
      unless session["devise.twitter_id"] # if no twitter_id session then
        redirect_to "/users/auth/twitter" # redirect to twitter
      end
  end
end