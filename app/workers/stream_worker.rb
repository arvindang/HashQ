class StreamWorker
  @queue = "stream_data"

  #include Amatch
  extend Amatch
  
  def self.perform(twt_data)
    #puts twt_data
    
    # Create record of tweet
    @tweet=Tweet.create(twt_data)
  
   
    if @tweet.in_reply_to_user_id_str.blank?
      p "In reply to:"
      p @tweet.in_reply_to_user_id_str
      p "Creating Poll"
      poll_create(@tweet)
    else
    
      if @tweet.text.include? "#r"
       p "Getting Results"
        poll_results(@tweet)
      else  
       p "Processing Vote"
        poll_vote(@tweet)
      end
    end
  
    #Output tweet text in terminal (informational)
   # user.screen_name does not work.  data was serialized, but ??
   # puts "#{twt_data.screen_name} #{twt_data.text}"
    
  end
  
###################################################################
  def self.poll_create(tweet)
    poll_text=tweet.text

    poll_regex=/#q([^?]+?)\?\s*((?:[^,]+(?:,|$))+)/

    return if poll_regex.match(poll_text).nil?

    # This gets the question
    question=poll_regex.match(poll_text)[1]

    #creates an array of answers
    answer_array=poll_regex.match(poll_text)[2].split(";")

    #Convert my array to a hash with poll result starting at 0
    answers_hash = {}
    answer_array.each { |i| answers_hash[i] = 0 }

    Poll.create(:tweet_id=>tweet.id, :id_str=>tweet.id_str ,:question=>question, :answers=>answers_hash)
    p "created poll"
    
    
  end

  def self.poll_vote(tweet)
    orig_poll=Poll.find_by_id_str(tweet.in_reply_to_status_id_str)
    category=category_match(tweet,orig_poll)  
    p "CLASSIFIED AS:"
    p category
    tweet.category=category
    tweet.save
    orig_poll.answers[category]+=1
    orig_poll.save
    p "saved category and added to tally"
  end

  def self.poll_results(tweet)
    orig_poll=Poll.find_by_id_str(tweet.in_reply_to_status_id_str)
    
    # Create title for graph
    title="Results: #{orig_poll.question}"
    
    #Create data for graph
    data=orig_poll.answers.values
    
    #Create lengend with key name from hash
    legend=orig_poll.answers.keys
    
    #Create a pie chart and sets a file name to save it to tmp directory
    chart = Gchart.new( :type => 'pie',
                        :title => title,
                        :data => data, 
                        :legend => legend,
                        :filename => "tmp/charts/#{tweet.id}.png")

    # Record file in filesystem (In other words Save the file)
    chart.file
    p "Saved chart"
    new_tweet=Twitter.new
    new_tweet.update_with_media("Results:",File.new("tmp/charts/#{tweet.id}.png"), options={:in_reply_to_status_id => 145609054084018176})
    p "sent tweet with image"
    
  end

  def self.category_match(tweet,mypoll)
    
    include Amatch
    
    #Define the match type (the method to search using the amatch gem)
    reply=LongestSubstring.new(tweet.text)

    #Create an array with the highest values being the best match
    score_longsub=reply.match(mypoll.answers.keys)

    #Create an array of the positions of the highest values
    score_positions=score_longsub.index_positions(score_longsub.max)

    #check if best score, if not use another match method to rescore.
    if score_positions.length>1

      #Define the match type (the method to search using the amatch gem)
      reply=JaroWinkler.new(tweet.text)

      #create an array of only the top score categories
      answers_short=score_positions.collect {|i| mypoll.answers.keys[i]}

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