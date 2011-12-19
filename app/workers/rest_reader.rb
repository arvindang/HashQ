# rails runner ....
require 'mymodule'
 
class RestReader
 
  extend Mymodule
  
  def self.sync
  
    @client = TweetStream::Client.new
    puts "tracking"

  
    #Continually loop through the stream as tweets come in and insert into DB
    @client.userstream do |status|
  
      begin
      p "GOT MESSAGE"
        
    
        if status.text.downcase.include? "#r"
          p "includes #r:"
          unless status.in_reply_to_user_id.blank?
            p "it is a reply:"
            p status.user.id
            if Oauth.find_by_uid(status.user.id)
                Resque.enqueue(TwitterRest,status.user.id)
            end
          end
        end
        
      rescue => e
        puts "Couldnt insert tweet. Possibly db lock error"
        puts e.message
        puts e.backtrace
        #Add error debugging here
      end
    end
  end
end