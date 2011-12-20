class AddImportUidToTweet < ActiveRecord::Migration
  def change
    add_column :tweets, :import_uid, :integer
  end
end
