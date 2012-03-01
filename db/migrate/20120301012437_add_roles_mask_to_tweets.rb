class AddRolesMaskToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :roles_mask, :integer
  end
end
