class Array

  #This method returns the locations of only any value (multiple locations)
  def index_positions(value)
    (0..(self.length)).select {|idx| self[idx] == value }
  end
  
end

#a = [10,3,5,7,4,10]
#a.index_positions(a.max)