require 'spec_helper'

describe StreamWorker do
  describe "#contain_hash_r?" do
    it  "is true when it contains #r" do
      tweet = Fabricate(:tweet, :text => "Here is a #reply")    
      StreamWorker.contain_hash_r?(tweet).should == true
    end
    
    it  "is false when it does not contains #r" do
      tweet = Fabricate(:tweet, :text => "Here is a reply")    
      StreamWorker.contain_hash_r?(tweet).should == false
    end
  end
end