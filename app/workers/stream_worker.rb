require 'array'

class StreamWorker


  @queue = "stream_data"

  #include Amatch
 
  def self.log(message)
    Rails.logger.info "[#{Time.now}] [Process #{$$}] [Stream Worker] #{message}"
    Rails.logger.flush
  end
 
  def self.perform(twt_data)
    
    @tweet=Tweet.create(twt_data)
    @tweet.process_twt_type
      
    log "1) Created record of tweet: #{@tweet.text}"
 
    if @tweet.in_reply_to_user_id.blank? || @tweet.in_reply_to_status_id.nil?
      log "2) in_reply_to_user/tweeter id is blank, creating Poll process"
      poll_create(@tweet)
   
    else
      
      log "2) In reply to: #{@tweet.in_reply_to_user_id}"
      if @tweet.text.downcase.include? "#r"
        log "3) includes #r, processing results"
        poll_results(@tweet)
      else  
       	log "3) does not include #r, processing Vote: #{@tweet.text}"
  	    poll_vote(@tweet)
      end
    end
  end
  
###################################################################
  # Methods for TDD
  
  def self.contain_hash_r?(tweet)
    tweet.text.include?("#r")
  end
  
###################################################################
  def self.poll_create(tweet)
    poll_text=tweet.text
    poll_regex=/#q([^?]+?)\?\s*((?:[^,]+(?:,|$))+)/i
    log "poll_regex: #{poll_regex}"

    return if poll_regex.match(poll_text).nil?
    
    # This gets the question
    question=poll_regex.match(poll_text)[1]||''

    #creates an array of answers
    answer_array=poll_regex.match(poll_text)[2].split(";")||''

    #Convert my array to a hash with poll result starting at 0
    answers_hash = {}
    answer_array.each { |i| answers_hash[i] = 0 }
    
    #Create poll
    new_poll = Poll.create(:tweet_id=>tweet.id, :twitter_tweet_id => tweet.twitter_tweet_id ,:question=>question, :answers=>answers_hash)
    log "created poll: #{new_poll}"
    
  end

  def self.poll_vote(tweet)
    #orig_poll=Poll.find_by_twitter_tweet_id(tweet.in_reply_to_status_id)
    orig_poll=tweet.orig_poll
    return if orig_poll.nil?
    tweet.save_poll_id
    
    return if tweet.orig_tweet.uid==tweet.uid
    
    p tweet.orig_tweet.uid
    p tweet.uid
   # return if tweet.orig_tweet.uid = tweet.uid
    
   
    
    log "pollvote, orig_poll: #{orig_poll.twitter_tweet_id}, in reply to status id: #{tweet.in_reply_to_status_id}"
    tweet.process_vote!
    log "saved category and added to tally"
    
    p reply_name=tweet.user['screen_name'] || ""
    
    p fix_answers=orig_poll.answers.keys
    p fix_answers.delete(tweet.category)
    
    p fix_answers
    list='['
    unless fix_answers.nil?
      fix_answers.each {|i| list +="#{i};"} 
      list=list.chomp(";")
      msg="[Auto-reply] You voted [#{tweet.category}]? If incorrect, reply #{list}]."
      p oauth=Oauth.find_by_uid(tweet.orig_tweet.uid)
      oauth.send_tweet("@#{reply_name} #{msg}", :in_reply_to_status_id =>tweet.twitter_tweet_id)
  	  p "@#{reply_name} #{msg}"
  	end
  
  end

  def self.poll_results(tweet)
   log "START POLL RESULTS:"
     #orig_poll=Poll.find_by_twitter_tweet_id(tweet.in_reply_to_status_id)
     orig_poll=tweet.orig_poll
     return if orig_poll.nil?
     tweet.save_poll_id
     
     reply_name=Tweet.find_by_twitter_tweet_id(tweet.orig_tweet.twitter_tweet_id).user['screen_name'] || ""
     log "Polling results: found orig_poll: #{orig_poll}"
     
    
    
    # Create title for graph
    time_stamp = Time.new.strftime('%S')
    title="Results (# #{time_stamp}): #{orig_poll.question}"
    str=''
   # title_a=title.scan(/.{30}\S*/)
   # title_chart = title_a.each {|i| str+=i+"|"}
     title_chart= title.length<35 ? title : "Results"

    log title
    #Create data for graph
    data=orig_poll.answers.values 
    data_sum=data.inject(0){|sum,item| sum + item}
    
    data_percent=data.map{|i| (i.to_f/data_sum*100).round(1)}
    #Create legend with key name from hash
    legend=orig_poll.answers.keys

    legend_percent=legend.zip(data_percent).map {|x,y|  x+" ("+y.to_s+"%)"}
    file_path="/tmp/#{tweet.id}.png"
    twt_title="@#{reply_name} #{title}"
    twt_title=twt_title.gsub(/^(.{85}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}


    #Create a pie chart and sets a file name to save it to tmp directory
    chart = Gchart.new( :type => 'pie',
                        :title => title_chart,
                        :data => data, 
                        :legend =>legend_percent,
                        :filename => file_path)

    # Record file in filesystem (In other words Save the file)
    chart.file
    log "Poll Results: Saved chart"
    new_tweet=Twitter.new
    if data_sum<2
    	new_tweet.update("@#{reply_name} Sorry, but you need at least 2 valid responses to create a #Hashqit chart.", :in_reply_to_status_id =>tweet.in_reply_to_status_id)
    else
    	new_tweet.update_with_media(twt_title,File.new(file_path), :in_reply_to_status_id =>tweet.in_reply_to_status_id)
    	log "Poll Results: sent tweet with image"
    	File.delete(file_path)
    	log "Poll Results: deleted image from server"
    end
    
  end

end
