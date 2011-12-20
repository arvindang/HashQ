module HomeHelper

    def tweet_errors(tweet = '')
      errors=[]
      poll_regex=/#q([^?]+?)\?\s*((?:[^,]+(?:,|$))+)/
      
      if tweet.length == 0
        errors=["Blank Tweet, Please enter a poll question."]+ errors
        return errors
      end
  
      if tweet.length > 140
        errors=["Make your tweet is less than 140 characters"]+ errors
      end
      if poll_regex.match(tweet).nil?
         errors = ["Make sure to match the #q format"]+ errors
      else
        answer_array=[]
        unless poll_regex.match(tweet)[2].nil?
          answer_array=poll_regex.match(tweet)[2].split(";")
        end

        unless answer_array.nil?
          if answer_array.length<2
            errors = ["Need at least two answers seperated with semi-colon"]+ errors
          end
        end
      end
  

      
      errors
      
    end

end