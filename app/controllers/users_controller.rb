class UsersController < ApplicationController
  layout :layout
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:show, :edit, :update, :suspend, :unsuspend, :destroy, :purge]

  # POST /users
  def create
    cookies.delete :auth_token

    @user = User.new(params[:user])
    @user.register! if @user.valid?
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  # PUT /users/1
  def update
    orig_email = @user.email
    
    if @user.update_attributes(params[:user])
      # Mark user as unconfirmed if email address changed
      if @user.email != orig_email
        @user.change_email!
        @user.reconfirm!
      end

      flash[:notice] = 'User was successfully updated'
    end
    
    render :action => "edit"
  end

  # PUT /users/1/edit
  def edit
    @preferences = Preference.find_by_user_id(current_user.id)
  end

  def confirm
    self.current_user = params[:confirmation_code].blank? ? false : User.find_by_confirmation_code(params[:confirmation_code])
    if logged_in? && !current_user.confirmed?
      current_user.confirm!
      flash[:notice] = "Email address confirmed"
    end
    redirect_back_or_default('/')
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end

  protected
  
  def find_user
    @user = User.find(params[:id])
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
