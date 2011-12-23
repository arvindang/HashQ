class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :place
      t.string :geo
      t.string :text
      t.string :retweet_count
      t.string :favorited
      t.text :activities
      t.string :coordinates
      t.string :in_reply_to_screen_name
      t.datetime :created_at
      t.string :in_reply_to_status_id_str
      t.integer :in_reply_to_status_id, :limit => 8
      t.string :source
      t.string :retweeted
      t.string :in_reply_to_user_id_str
      t.string :truncated
      t.string :id_str
      t.integer :in_reply_to_user_id, :limit=> 8
      t.string :contributors
      t.integer :twitter_tweet_id, :limit => 8
      t.integer :uid
      t.text :user
      t.string :category

      t.timestamps
    end
  end
end
