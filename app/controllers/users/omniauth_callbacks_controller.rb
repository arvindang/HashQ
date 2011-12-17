class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def twitter

    oauth = Oauth.find_or_create_twitter(request.env["omniauth.auth"])
    @user=oauth.user

    if @user    #(.persisted?)
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_id"] = request.env["omniauth.auth"].uid
      p "save session and redirect"
      redirect_to new_user_registration_url
    end
  end
end



