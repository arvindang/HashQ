# rails runner ....

class StreamReader
  def self.sync
  
    @client = TweetStream::Client.new
    puts "tracking"
  
 
  
    #Used for debugging, but don't really understand it (not really used now)
    error_proc = Proc.new do |error|
      p error
    end
  
    #Continually loop through the stream as tweets come in and insert into DB
    @client.userstream do |status|
  
      begin
      
        twt_data = { 
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
                     :user => status.user
                     #category needs to be inserted on later on processing
                   }
    
      # Checks if status has activities key, if it does it sets value
       if status.has_key?(:activities) 
         twt_data[:activies] = status.activities
       end
   
        p twt_data
        
        Resque.enqueue(StreamWorker, twt_data)
   
      rescue => e
        puts "Couldnt insert tweet. Possibly db lock error"
        puts e.message
        puts e.backtrace
        #Add error debugging here
      end
    end
  end
end