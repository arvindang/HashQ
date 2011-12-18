# rails runner ....

class TwitterRest
  def self.sync
  
    connect= Oauth.all
    
    Connect.each do |record|
    
        record.
        
        record.sign_in
        @client = Twitter.new
        
        
        @client.home.timeline.each 
  
      begin

   
      rescue => e
        puts "Couldnt insert tweet. Possibly db lock error"
        puts e.message
        puts e.backtrace
        #Add error debugging here
      end
    end
  end
end