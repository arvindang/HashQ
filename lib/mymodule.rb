module Mymodule
  
  
  def twitter_hash(status)
           hashit=   { 
                  :place  => status['place'], 
                  :geo => status['geo'],
                  :text => status['text'],
                  :retweet_count => status['retweet_count'],
                  :favorited => status['favorited'],
                  :activities => status['activities'], 
                  :coordinates => status['coordinates'], 
                  :in_reply_to_screen_name => status['in_reply_to_screen_name'], 
                  :created_at => status['created_at'], 
                  :in_reply_to_status_id_str => status['in_reply_to_status_id_str'], 
                  :in_reply_to_status_id => status['in_reply_to_status_id'],
                  :source => status['source'],
                  :retweeted => status['retweeted'], 
                  :in_reply_to_user_id_str => status['in_reply_to_user_id_str'],
                  :truncated => status['truncated'],
                  :id_str => status['id_str'],
                  :in_reply_to_user_id => status['in_reply_to_user_id'],
                  :contributors => status['contributors'],
                  :twitter_tweet_id => status['id'],
                  :uid => status['user']['id'],
                  :user => status['user']
                  #category needs to be inserted on later on processing
                }
                 
          hashit
  end  
  
  def tweet_hash(status)
      hashit=    { 
                  :place  => status.place, 
                  :geo => status.geo,
                  :text => status.text,
                  :retweet_count => status.retweet_count,
                  :favorited => status.favorited,
                  # Inserts :activies => status.activities below only if available 
                  :coordinates => status.coordinates, 
                  :in_reply_to_screen_name => status.in_reply_to_screen_name, 
                  :created_at => status.created_at, 
                  :in_reply_to_status_id_str => status.in_reply_to_status_id_str, 
                  :in_reply_to_status_id => status.in_reply_to_status_id,
                  :source => status.source,
                  :retweeted => status.retweeted, 
                  :in_reply_to_user_id_str => status.in_reply_to_user_id_str,
                  :truncated => status.truncated,
                  :id_str => status.id_str,
                  :in_reply_to_user_id => status.in_reply_to_user_id,
                  :contributors => status.contributors,
                  :twitter_tweet_id => status.id,
                  :uid => status.user.id,
                  :user => status.user
                  #category needs to be inserted on later on processing
                }

                # Checks if status has activities key, if it does it sets value
                 if status.has_key?(:activities) 
                   hashit[:activies] = status.activities
                 end
                 hashit
  end
  
  
end
