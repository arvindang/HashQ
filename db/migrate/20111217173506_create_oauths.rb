class CreateOauths < ActiveRecord::Migration
  def change
    create_table :oauths do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email
      t.string :nickname
      t.string :first_name
      t.string :last_name
      t.string :location
      t.string :description
      t.string :image
      t.string :phone
      t.text   :urls
      t.string :oauth_token
      t.string :oauth_secret
      t.text   :extra
      t.integer :user_id

      t.timestamps
    end
  end
end
