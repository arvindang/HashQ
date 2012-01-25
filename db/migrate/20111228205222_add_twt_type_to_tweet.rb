class AddTwtTypeToTweet < ActiveRecord::Migration
  def change
    add_column :tweets, :twt_type, :string
  end
end
