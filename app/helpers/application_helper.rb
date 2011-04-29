module ApplicationHelper
  def current_user
    session[:twitter_id]
  end
  
  def current_user?
    !(current_user.nil?)
  end
end
