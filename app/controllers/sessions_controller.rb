class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    if user = User.find_by_uid(auth["uid"])
      login_and_redirect_to(user, "/users/#{ user.id }")
    else
      user = User.create_with_omniauth(auth)
      login_and_redirect_to(user, '/welcome/newbie')
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => t('helpers.action.logout')
  end

  def failure
    redirect_to root_url, :notice => t('helpers.action.login_failure', msg: params[:message] || '')
  end

  private
  def login_and_redirect_to(user, page)
    session[:user_id] = user.id
    redirect_to page, :notice => t('helpers.action.login')
  end
end
