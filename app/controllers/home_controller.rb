class HomeController < ApplicationController
  def index
    
    
    if user_signed_in? 
      if session['q_tweet'] = nil
       
        oauth=Oauth.find_by_user_id_and_provider(current_user,'twitter')
        oauth.sign_in
        Twitter.new
        Twitter.update(session['q_tweet'])
        session=nil
        flash[:notice]="#q Tweet Sent! Awesome!"
        redirect_to root_path
      end
    end
  end

  def create
    session['q_tweet']=params['q']
    if user_signed_in?
      redirect_to root_path
      
      
      
      
    else
      redirect_to '/users/auth/twitter'
    end
  end
  
end
