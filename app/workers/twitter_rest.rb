# rails runner ....
require 'mymodule'

class TwitterRest

@queue = "rest_data"

extend Mymodule
  
  def self.sync
    
    oauth=Oauth.all
    oauth.each do |user|
      get_tweets(user.uid)
     # p "x"*40
     # p "x"
     # p "x"
    end
    
  end
  
  def self.perform(uid)
      p "Sent to be processed"
      p uid
      get_tweets(uid)
  end
    
  
  def self.get_tweets(uid)
  
      oauth=Oauth.find_by_uid(uid)
      oauth.sign_in
      Twitter.new
      twts=[]
      
      #maxtwt=oauth.tweets.max{ |a,b| a.created_at <=> b.created_at }
      maxtwt=oauth.tweets.order("created_at desc").where(:import_uid => uid).first
      #p "MAX TWEET"
      
      for i in 1..20 do
    
        if maxtwt
       #   p maxtwt.twitter_tweet_id
          "get home_timelines with max id_str"
        #  p "page:"
         # p i

          twt_data=Twitter.user_timeline(:count=>200, :page=>i, :since_id=>maxtwt.twitter_tweet_id )
        else
          "get home_timeline no max"
          twt_data=Twitter.user_timeline(:count=>50, :page=>1)
        end
        break if twt_data == [] || twt_data.min{|i| i.id}.id < maxtwt
        twts+=twt_data
      end

      if maxtwt
	twts.find_all{|i| i.id>maxtwt}
      end
	  
      twts.sort!{ |a,b| a.created_at <=> b.created_at }
  
      twts.each do |status|
         # p "inside of each do UID:"
         # p uid
          twt_data= twitter_hash(status)
          twt_data[:import_uid] = uid
         # p twt_data
          Resque.enqueue(StreamWorker, twt_data)
      end
  
  end
end
