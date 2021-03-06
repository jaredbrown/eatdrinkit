# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  layout 'default'

  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      session[:current_user] = self.current_user
      if session[:redirect_to].nil?
        redirect_back_or_default('/')
      else
        redirect_to session[:redirect_to]
        session[:redirect_to] = nil
      end
      flash[:notice] = "Logged in"
    else
      flash[:notice] = 'Login failed'
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to :places
  end
  
  private
  
  def layout
    if(params[:action] == 'index' or params[:action] == 'edit' or params[:action] == 'update' or params[:action] == 'show')
      return 'default'
    else
      return 'blank'
    end
  end
end
