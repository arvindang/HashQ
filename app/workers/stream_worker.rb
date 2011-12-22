class StreamWorker
  @queue = "stream_data"

  #include Amatch
  extend Amatch
  
  def self.perform(twt_data)
    # Create record of tweet
    @tweet=Tweet.create(twt_data)
   
    if @tweet.in_reply_to_user_id.blank?
    #  p "In reply to:"
      p @tweet.in_reply_to_user_id
      p "Creating Poll"
      poll_create(@tweet)
    else
    
      if @tweet.text.downcase.include? "#r"
       p "Getting Results"
        poll_results(@tweet)
      else  
       p "Processing Vote"
        poll_vote(@tweet)
      end
    end
  end
  
###################################################################
  def self.poll_create(tweet)
    poll_text=tweet.text

    poll_regex=/#q([^?]+?)\?\s*((?:[^,]+(?:,|$))+)/i

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
    p "created poll:"
    #p new_poll
    
  end

  def self.poll_vote(tweet)
    orig_poll=Poll.find_by_twitter_tweet_id(tweet.in_reply_to_status_id)
 
    if orig_poll
      category=category_match(tweet,orig_poll)  
      p "CLASSIFIED AS:"
      p category
      tweet.category=category
      tweet.save
      orig_poll.answers[category]+=1
      orig_poll.save
      p "saved category and added to tally"
    end
 
  end

  def self.poll_results(tweet)
    orig_poll=Poll.find_by_twitter_tweet_id(tweet.in_reply_to_status_id)
    
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
    new_tweet.update_with_media("Results:",File.new("tmp/charts/#{tweet.id}.png"), :in_reply_to_status_id =>tweet.in_reply_to_status_id)
    p "sent tweet with image"
    File.delete("tmp/charts/#{tweet.id}.png")
    "deleted image from server"
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

