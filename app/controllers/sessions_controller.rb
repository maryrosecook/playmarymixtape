# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:user][:email], params[:user][:password])
    if logged_in?
      current_user.remember_me unless current_user.remember_token?
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at, :domain => Linking.cookie_domain }
      redirect_to(current_user.audiography.get_url())
      flash[:notice] = "Logged in."
    else
      flash[:notice] = "Wrong email or password."
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    #cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default("/")
  end
end
