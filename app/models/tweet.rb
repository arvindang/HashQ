class Tweet < ActiveRecord::Base

  #Creates a one to many relationship, can use "tweets.poll" to get poll orginal poll.
  
  has_one :poll
  
  serialize :user
  serialize :activities
  
  validates_uniqueness_of :twitter_tweet_id
  
  
  
  def orig_tweet(depth = 1)
     if depth == 10 || in_reply_to_status_id.nil?
       self
     else
       Tweet.find_by_twitter_tweet_id(self.in_reply_to_status_id).orig_tweet(depth+1)
     end
   end
  
   # def orig_tweet
   #       Tweet.find_by_twitter_tweet_id(self.in_reply_to_status_id).try(:orig_tweet) || self
   #     end
  
end
