class Poll < ActiveRecord::Base
  
  #allows for arrays and hashes to be stored in answer field column
  serialize :answers
  
  #Creates a one to many relationship, can use "poll.replies" to get replies for poll
  has_many :replies, :class_name => 'Tweet', :primary_key => 'poll_id',  :foreign_key => 'poll_id'
  
  #Create a one to one relationship you can use "Poll.Tweet" to get original Tweet with question.
  belongs_to :tweet

  def tally(category,adjust_by=1)
    self.answers[category]+=adjust_by
    self.save
  end
end
