class HomeController < ApplicationController
 include HomeHelper
 
  def index
    @sent_tweet=session[:sent_tweet] 
    session[:sent_tweet]=nil
    if user_signed_in? 
      if session['q_tweet']
        oauth=Oauth.find_by_user_id_and_provider(current_user,'twitter')
        oauth.send_tweet(session['q_tweet'])
        session['q_tweet']= nil
        session[:sent_tweet]="#q Tweet Sent! Awesome!"  
        redirect_to root_path
      end
    end
    
  end

  def create
   @twt=params['q'] 
    
    @errors=tweet_errors(@twt)
    
      
      if @errors.length>0
        render :action => "index"
      else
        session['q_tweet']=params['q']
    
        if user_signed_in?
          redirect_to root_path
        else
          redirect_to '/users/auth/twitter'
        end  
      end
  end
end
