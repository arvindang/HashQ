# rails runner ....
require 'mymodule'
 
class RestReader
 
  extend Mymodule

def self.log(message)
  Rails.logger.info "[#{Time.now}] [Process #{$$}] [REST READER] #{message}"
  Rails.logger.flush
end
  
  def self.sync
    log "syncing"
  
    @client = TweetStream::Client.new
 
    log "tracking"

  
    #Continually loop through the stream as tweets come in and insert into DB
    @client.userstream do |status|
  
      begin
      log "GOT MESSAGE"
        
    
        if status.text.downcase.include? "#r"
          log "includes #r:"
          unless status.in_reply_to_user_id.blank?
            log "it is a reply:"
            log status.user['screen_name']
             

            if Oauth.find_by_uid(status.user.id) && status.in_reply_to_user_id==status.user.id
             	log "sent to resque"
		   Resque.enqueue(TwitterRest,status.user.id)
	     else
		log "could not find Oauth or reply and poster not the same- END"
	 	log "#{status.in_reply_to_user_id}:  #{status.user.id}"
            end
          end
        end
        
      rescue => e
        log "Couldnt insert tweet. Possibly db lock error"
        log e.message
        log e.backtrace
        #Add error debugging here
      end
    end
  end
end
