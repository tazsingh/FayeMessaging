class SessionsController < ApplicationController
  def create
    session[:twitter_id] = request.env["omniauth.auth"]["user_info"]["nickname"]
    redirect_to root_url
  end
  
  def new
    
  end
end
