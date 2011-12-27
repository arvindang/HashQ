class StreamWorker


  @queue = "stream_data"

  #include Amatch
  extend Amatch
 
def self.log(message)
  Rails.logger.info "[#{Time.now}] [Process #{$$}] [Stream Worker] #{message}"
  Rails.logger.flush
end
 
  def self.perform(twt_data)
    log "Create record of tweet"
    @tweet=Tweet.create(twt_data)
    log @tweet.text
 
    if @tweet.in_reply_to_user_id.blank?
    log "In reply to:"
    log @tweet.in_reply_to_user_id
    log "Creating Poll"
      poll_create(@tweet)
    else
    
      if @tweet.text.downcase.include? "#r"
        log "Getting Results"
        poll_results(@tweet)
      else  
       	log "Processing Vote"
      	log @tweet.text
  	poll_vote(@tweet)
      end
    end
  end
  
###################################################################
  def self.poll_create(tweet)
    poll_text=tweet.text

    poll_regex=/#q([^?]+?)\?\s*((?:[^,]+(?:,|$))+)/i
    log "poll_regex"
    log poll_regex

    return if poll_regex.match(poll_text).nil?
    
    # This gets the question
    question=poll_regex.match(poll_text)[1]||''

    #creates an array of answers
    answer_array=poll_regex.match(poll_text)[2].split(";")||''

    #Convert my array to a hash with poll result starting at 0
    answers_hash = {}
    answer_array.each { |i| answers_hash[i] = 0 }
    
    #p "before create:"
    #p tweet.id
    #p tweet.twitter_tweet_id
    #p question
    #p answers_hash
    #p "xxxxxxxxxxxxxxxxxxxxx"
    new_poll = Poll.create(:tweet_id=>tweet.id, :twitter_tweet_id => tweet.twitter_tweet_id ,:question=>question, :answers=>answers_hash)
    log "created poll:"
    log new_poll
    
  end

  def self.poll_vote(tweet)
    orig_poll=Poll.find_by_twitter_tweet_id(tweet.in_reply_to_status_id)
    log "orig_poll"
    log orig_poll
    log "in reply to status id"
    log tweet.in_reply_to_status_id
    return if orig_poll.nil?

    if orig_poll
      category=category_match(tweet,orig_poll)  
      log "CLASSIFIED AS:"
      log category
      tweet.category=category
      tweet.save
      orig_poll.answers[category]+=1
      orig_poll.save
      log "saved category and added to tally"
    end
 
  end

  def self.poll_results(tweet)
   log "START POLL RESULTS:"
     orig_poll=Poll.find_by_twitter_tweet_id(tweet.in_reply_to_status_id)
    
    reply_name=Tweet.find_by_twitter_tweet_id(tweet.in_reply_to_status_id).user['screen_name'] || ""
    log "orig_poll"
    log orig_poll
    return if orig_poll.nil?
    log "found poll"
    # Create title for graph
    title="Results: #{orig_poll.question}"
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
    log "Saved chart"
    new_tweet=Twitter.new
    if data_sum<2
    	new_tweet.update("@#{reply_name} Sorry, but you need at least 2 valid responses to create a #Hashqit chart.", :in_reply_to_status_id =>tweet.in_reply_to_status_id)
    else
    	new_tweet.update_with_media(twt_title,File.new(file_path), :in_reply_to_status_id =>tweet.in_reply_to_status_id)
    	log "sent tweet with image"
    	File.delete(file_path)
    	log "deleted image from server"
    end
  end

  def self.category_match(tweet,mypoll)
    
    include Amatch
    twt_text=tweet.text.gsub(/^@\w{1,15}/i, '').downcase 
    twt_answers=mypoll.answers.keys.map {|i| i.downcase}
    #Define the match type (the method to search using the amatch gem)
    reply=LongestSubstring.new(twt_text)

    log twt_text
    log twt_answers

    #Create an array with the highest values being the best match
    score_longsub=reply.match(twt_answers)
    log "Highest match number: #{score_longsub.max}"
    log score_longsub
    
    #Create an array of the positions of the highest values
    score_positions=score_longsub.index_positions(score_longsub.max)

    score_positions=score_longsub.index_positions(score_longsub.max)

    #check if best score, if not use another match method to rescore.
    if score_positions.length>1

      #Define the match type (the method to search using the amatch gem)
      reply=JaroWinkler.new(twt_text)

      #create an array of only the top score categories
      answers_short=score_positions.collect {|i| twt_answers[i]}

      #Create an array with the highest values being the best match
      score_jarow=reply.match(answers_short)

      #Create an array of the positions of the highest values
      score_positions=score_jarow.index_positions(score_jarow.max)

      answers_short[score_positions.first] 

    else
      mypoll.answers.keys[score_positions.first]
    end
  end
end
