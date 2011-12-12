class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.integer :tweet_id
      t.string :id_str
      t.string :question
      t.text :answers

      t.timestamps
    end
  end
end
