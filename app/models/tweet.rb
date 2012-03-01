class Tweet < ActiveRecord::Base

  #after_create :save_poll_id
  
  #Creates a one to many relationship, can use "tweets.poll" to get poll orginal poll.
  
  has_one :poll
  
  serialize :user
  serialize :activities
  
  validates_uniqueness_of :twitter_tweet_id





####################################################################
  
  extend Amatch
  include Amatch
  
  def orig_tweet(depth = 1)
     if depth == 100 || in_reply_to_status_id.nil?
         self       
     else
       if Tweet.find_by_twitter_tweet_id(self.in_reply_to_status_id)
          Tweet.find_by_twitter_tweet_id(self.in_reply_to_status_id).orig_tweet(depth+1)
       else
         p "orig_tweet: Can not find tweet from in_reply_to_status_id"
         nil
       end
     end
   end
  
  def orig_poll
    nil
    Poll.find_by_twitter_tweet_id((self.orig_tweet.twitter_tweet_id unless self.orig_tweet.nil?))
  end
  
  def save_poll_id
    self.poll_id=self.orig_poll.id
    self.save
  end
  
   # def orig_tweet
   #       Tweet.find_by_twitter_tweet_id(self.in_reply_to_status_id).try(:orig_tweet) || self
   #     end
  
  def unvote!
    if self.category.blank?
      #do nothing
      false
    else
      self.orig_poll.tally(self.category,-1)
      self.category=''
      self.twt_type='vote_void'
      self.save
      true
    end
  end

  def vote!
    self.category=self.category_match
    self.orig_poll.tally(self.category)
    self.twt_type='vote'
    self.save
  end
  
  def current_vote
    Tweet.where(:uid => self.uid, :poll_id => self.orig_poll,:twt_type=>'vote').where("category IS NOT NULL OR category !=''").order('created_at DESC').first
    #"category IS NOT NULL OR category !=''"
  end
  
  def process_vote!
      nil
      return if self.orig_poll.nil?
      self.current_vote.unvote! unless current_vote.nil?
      self.vote!
  end

  def process_twt_type
   
      poll_text=self.text
      poll_regex=/#q([^?]+?)\?\s*((?:[^,]+(?:,|$))+)/i
   
      mask=[] 
      mask << 'root_twt'                if self.in_reply_to_status_id.nil?
      mask << 'match_q'                 unless poll_regex.match(poll_text).nil?
      mask << 'has_poll'                unless self.orig_poll.nil?
      mask << 'includes_r'              if self.text.downcase.include?('#r')
      mask << 'includes_q'              if self.text.downcase.include?('#q')
      mask << 'from_hashq'              if self.uid=='433563171'
      mask << 'from_orig_twt_creater'   if self.uid==self.orig_tweet.uid
    
      self.roles=(mask)
            
      case self.roles_mask
        
        when roles_value(%w[root_twt match_q])
          #poll
          self.update_attribute(:twt_type,'poll')
          
          #Create Poll!
          StreamWorker.poll_create(self)
          
        when roles_value(%w[match_q])
          #poll_not_root_twt
          self.update_attribute(:twt_type,'poll_not_root_twt')
        
        when roles_value(%w[root_twt includes_q])
          #poll_no_match_q
          self.update_attribute(:twt_type,'poll_no_match_q')
        
        when roles_value(%w[includes_q])
          #poll_no_match_q_and_not_root_twt
          self.update_attribute(:twt_type,'poll_no_match_q_and_not_root_twt')
        
        when roles_value(%w[includes_r has_poll from_orig_twt_creater])
          #result_request
          self.update_attribute(:twt_type,'result_request')
          
          # Process Results!
          StreamWorker.poll_results(self)
          
        when roles_value(%w[includes_r has_poll])
          #results_not_poll_creater
          self.update_attribute(:twt_type,'results_not_poll_creater')
        
        when roles_value(%w[includes_r])
          #results_no_poll_and_not_poll_creater
          self.update_attribute(:twt_type,'results_no_poll_and_not_poll_creater')
          
        when roles_value(%w[has_poll from_hashq])
          #automatic_ignore_hashq
          self.update_attribute(:twt_type,'automatic_ignore_hashq')
        
        when roles_value(%w[has_poll from_orig_twt_creater])
          #automatic_ignore_poll_creater
          self.update_attribute(:twt_type,'automatic_ignore_poll_creater')
        when roles_value(%w[has_poll])
          #vote
          self.update_attribute(:twt_type,'vote')
          
          # Process Vote!
          StreamWorker.poll_vote(self)
    	    
        else
          #tweet
          self.update_attribute(:twt_type,'tweet')
      end
  
         
      unless [  'poll', 
                'request_result', 
                'vote', 
                'automatic_ignore_hashq', 
                'automatic_ignore_poll_creater',
                'tweet'
                ].include? self.twt_type
        
        new_tweet=Twitter.new  
        reply_name=self.user['screen_name'] || ""    
        #new_tweet.update("@#{reply_name} You made a mistake[error]: #{self.twt_type}", :in_reply_to_status_id =>self.twitter_tweet_id)
      end
         
  end
  
  
  def category_match
    mypoll=self.orig_poll
    
    twt_text=self.text.gsub(/^@\w{1,15}/i, '').downcase 
    twt_answers=mypoll.answers.keys.map {|i| i.downcase}
    #Define the match type (the method to search using the amatch gem)
    reply=LongestSubstring.new(twt_text)

    #Create an array with the highest values being the best match
    score_longsub=reply.match(twt_answers)
    
    #log "Highest match number: #{score_longsub.max}"
    #log score_longsub
    
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
  





#### Tweet Attributes Roles to identify Tweet Type #####


#Define Tweet Atrributes in ROLES
ROLES = %w[  root_twt
             match_q
             has_poll
             includes_r
             includes_q
             from_hashq
             from_orig_twt_creater
          ]
    

    # Create scope to query based on role_mask
    scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }
    
    # Note: (2**==2^, "roles & ROLES" is a bitmask "AND" operator that returns the mask value or 0)

    # Assign Roles to roles_mask field 
    def roles=(roles)
      self.roles_mask = roles_value(roles)
    end

    def roles_value(roles)
      (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
    end

    # Returns the items in the bit mask (decodes the bitmask)
    def roles
      ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
    end

    # Not used as far as I can see
    def role_symbols
      roles.map(&:to_sym)
    end
end
