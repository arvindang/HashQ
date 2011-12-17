# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111217173506) do

  create_table "oauth_users", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "nickname"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "location"
    t.string   "image"
    t.string   "phone"
    t.text     "urls"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.text     "raw_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauths", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "nickname"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "location"
    t.string   "image"
    t.string   "phone"
    t.text     "urls"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.text     "extra"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "polls", :force => true do |t|
    t.integer  "tweet_id"
    t.string   "id_str"
    t.string   "question"
    t.text     "answers"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tweets", :force => true do |t|
    t.string   "place"
    t.string   "geo"
    t.string   "text"
    t.string   "retweet_count"
    t.string   "favorited"
    t.text     "activities"
    t.string   "coordinates"
    t.string   "in_reply_to_screen_name"
    t.datetime "created_at"
    t.string   "in_reply_to_status_id_str"
    t.string   "in_reply_to_status_id"
    t.string   "source"
    t.string   "retweeted"
    t.string   "in_reply_to_user_id_str"
    t.string   "truncated"
    t.string   "id_str"
    t.string   "in_reply_to_user_id"
    t.string   "contributors"
    t.text     "user"
    t.string   "category"
    t.datetime "updated_at"
  end

end
