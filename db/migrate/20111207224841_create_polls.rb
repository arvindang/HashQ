class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.integer :tweet_id
      t.integer :twitter_tweet_id, :limit => 8
      t.string :question
      t.text :answers

      t.timestamps
    end
  end
end
