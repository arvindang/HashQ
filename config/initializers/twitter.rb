# Following ENV[] variables should be stored in system not code.


[TweetStream,Twitter].each do |twt|
  twt.configure do |config|
    config.consumer_key = ENV['twitter_ck']
    config.consumer_secret = ENV['twitter_cs']
    config.oauth_token = ENV['twitter_at']
    config.oauth_token_secret = ENV['twitter_ats']
  end
end

TweetStream.configure do |config|
config.auth_method = :oauth
config.parser   = :yajl
end