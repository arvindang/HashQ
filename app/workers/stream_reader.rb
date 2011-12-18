# rails runner ....
require 'mymodule'
 
class StreamReader
 
  extend Mymodule
  
  def self.sync
  
    @client = TweetStream::Client.new
    puts "tracking"

  
    #Continually loop through the stream as tweets come in and insert into DB
    @client.userstream do |status|
  
      begin
      p "GOT MESSAGE"

        twt_data= tweet_hash(status)
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