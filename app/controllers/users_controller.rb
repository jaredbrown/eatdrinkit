class UsersController < ApplicationController
  layout 'default'
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:show, :suspend, :unsuspend, :destroy, :purge]

  # GET /users/1
  def show
    @user = User.find(params[:id])
    @reviews = Review.find_all_by_user_id(params[:id])
  end

  # GET /users/activies
  def activities
    per_page = 10
    
    @reviews = Review.paginate(:page => params[:page], :per_page => per_page, :limit => 20, :order => 'created_at DESC')
  end
  
  # GET /users/settings
  def settings
    @current_user = session[:current_user]
    @current_user.errors.clear
    
    if @current_user.nil?
      redirect_to '/login'
      session[:redirect_to] = '/users/settings'
    end
  end

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
    @current_user = session[:current_user]
    @current_user.attributes = params[:current_user]
    
    if @current_user.save
      flash[:notice] = 'Update successful'
    else
      @current_user.reload
    end
    
    @current_user.password = nil
    @current_user.password_confirmation = nil
    
    render :action => 'settings'
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
