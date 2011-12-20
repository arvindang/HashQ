class Tweet < ActiveRecord::Base

  #Creates a one to many relationship, can use "tweets.poll" to get poll orginal poll.
  
  has_one :poll
  
  serialize :user
  serialize :activities
  
  validates_uniqueness_of :twitter_tweet_id
end
