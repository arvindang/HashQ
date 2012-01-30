class Tweet < ActiveRecord::Base

  #after_create :save_poll_id
  
  #Creates a one to many relationship, can use "tweets.poll" to get poll orginal poll.
  
  has_one :poll
  
  serialize :user
  serialize :activities
  
  validates_uniqueness_of :twitter_tweet_id





####################################################################
  
  extend Amatch
  include Amatch
  
  def orig_tweet(depth = 1)
     if depth == 100 || in_reply_to_status_id.nil?
       self
     else
       if Tweet.find_by_twitter_tweet_id(self.in_reply_to_status_id)
          Tweet.find_by_twitter_tweet_id(self.in_reply_to_status_id).orig_tweet(depth+1)
       else
         p "orig_tweet: Can not find tweet from in_reply_to_status_id"
       end
     end
   end
  
  def orig_poll
    Poll.find_by_twitter_tweet_id((self.orig_tweet.twitter_tweet_id unless self.orig_tweet.nil?))
  end
  
  def save_poll_id
    self.poll_id=self.orig_poll.id
    self.save
  end
  
   # def orig_tweet
   #       Tweet.find_by_twitter_tweet_id(self.in_reply_to_status_id).try(:orig_tweet) || self
   #     end
  
  def unvote!
    if self.category.blank?
      #do nothing
      false
    else
      self.orig_poll.tally(self.category,-1)
      self.category=''
      self.twt_type='vote_void'
      self.save
      true
    end
  end

  def vote!
    self.category=self.category_match
    self.orig_poll.tally(self.category)
    self.twt_type='vote'
    self.save
  end
  
  def current_vote
    Tweet.where(:uid => self.uid, :poll_id => self.orig_poll,:twt_type=>'vote').where("category IS NOT NULL OR category !=''").order('created_at DESC').first
    #"category IS NOT NULL OR category !=''"
  end
  
  def process_vote!
      nil
      return if self.orig_poll.nil?
      self.current_vote.unvote! unless current_vote.nil?
      self.vote!
  end

  def process_twt_type
    # enters the type of twwet, poll, new vote, revote, request for result, crap 
  end
  
    
  def category_match
    mypoll=self.orig_poll
    
    twt_text=self.text.gsub(/^@\w{1,15}/i, '').downcase 
    twt_answers=mypoll.answers.keys.map {|i| i.downcase}
    #Define the match type (the method to search using the amatch gem)
    reply=LongestSubstring.new(twt_text)

    #Create an array with the highest values being the best match
    score_longsub=reply.match(twt_answers)
    
    #log "Highest match number: #{score_longsub.max}"
    #log score_longsub
    
    #Create an array of the positions of the highest values
    score_positions=score_longsub.index_positions(score_longsub.max)

    score_positions=score_longsub.index_positions(score_longsub.max)

    #check if best score, if not use another match method to rescore.
    if score_positions.length>1

      #Define the match type (the method to search using the amatch gem)
      reply=JaroWinkler.new(twt_text)

      #create an array of only the top score categories
      answers_short=score_positions.collect {|i| twt_answers[i]}

      #Create an array with the highest values being the best match
      score_jarow=reply.match(answers_short)

      #Create an array of the positions of the highest values
      score_positions=score_jarow.index_positions(score_jarow.max)

      answers_short[score_positions.first] 

    else
      mypoll.answers.keys[score_positions.first]
    end
  end
  






end
