class PollsController < ApplicationController

 before_filter :authenticate_user!  

  def index  
    if user_signed_in?
      @user = current_user
      @tweets=Tweet.find_all_by_twt_type_and_uid('poll',@user.oauth.last.uid)    
      @poll=@tweets.first.poll
      @answers=pa(@poll)
      render :layout => 'poll_layout'
    end


  end


  def show
    @user = current_user
    @poll=Poll.find(params[:id])
    @answers=pa(@poll)
    render :layout => 'poll_layout'
  end



private


  def pa(poll)
    poll.answers.keys.inject({}) do |answer_hash, answer|
      p poll.replies.find_all_by_category(answer).count
      answer_hash[answer] = poll.replies.find_all_by_category(answer)
      answer_hash
    end
  end

 
 ## needs a lot of work....

 # def pa_x(user) 
 #    tweets=Tweet.find_all_by_twt_type_and_uid('poll',@user.oauth.last.uid)    
 #    
 #    polls = Poll.all.inject({}) do |poll_hash, poll|
 #      poll_hash[poll] = poll.answers.inject({}) do |answer_hash, answer|
 #        answer_hash[answer] = Tweet.find_all_by_category(answer)
 #        answer_hash
 #      end
 #    poll_hash
 #  end
 #  
  # { #<Poll 1> => { #<Answer 1> => [#<Vote 1>, #<Vote 2>, ...] }, 
  #                          { #<Answer 2> => [...] },
  #                          ... }
  #   #<Poll 2> => ...,
  # }
  
  
  
  

end
