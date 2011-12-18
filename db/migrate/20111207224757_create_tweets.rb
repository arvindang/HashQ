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
      t.string :in_reply_to_status_id
      t.string :source
      t.string :retweeted
      t.string :in_reply_to_user_id_str
      t.string :truncated
      t.string :id_str
      t.string :in_reply_to_user_id
      t.string :contributors
      t.integer :status_id
      t.string :uid
      t.text :user
      t.string :category

      t.timestamps
    end
  end
end
