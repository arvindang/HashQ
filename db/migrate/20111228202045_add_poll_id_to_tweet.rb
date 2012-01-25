class AddPollIdToTweet < ActiveRecord::Migration
  def change
    add_column :tweets, :poll_id, :integer
  end
end
