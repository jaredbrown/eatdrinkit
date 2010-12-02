class UsersController < ApplicationController
  layout 'default'
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:show, :suspend, :unsuspend, :destroy, :purge]
  
  before_filter :clear_sessions, :only => [:settings]

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
    flash[:notice] = nil
    @foursquare_oauth_url = foursquare_oauth_url unless @current_user.enable_foursquare
    @twitter_oauth_url = twitter_oauth_url unless @current_user.enable_twitter
    
    if @current_user.nil?
      redirect_to '/login'
      session[:redirect_to] = '/users/settings'
    else
      @current_user.errors.clear
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
    end
    
    @current_user.reload
    @current_user.password = nil
    @current_user.password_confirmation = nil
    
    render :action => 'settings'
  end
  
  def update_social
    @current_user = session[:current_user]
    
    if params['method'] == 'foursquare' || params['method'] == 'twitter'
      method = params['method']
    else
      return redirect_to '/users/settings'
    end
    
    if params['value'] == 'enable'
      request_token = session[method + '_request_token']
      access_token = request_token.get_access_token :oauth_verifier => params['oauth_verifier']
      @current_user['enable_' + method] = true
      @current_user[method + '_oauth_token'] = access_token.token
      @current_user[method + '_oauth_secret'] = access_token.secret
    elsif params['value'] == 'disable'
      @current_user['enable_' + method] = false
      @current_user[method + '_access_token'] = nil
      @current_user[method + '_access_secret'] = nil
    else
      return redirect_to '/users/settings'
    end
    
    @current_user.save!
    
    return redirect_to '/users/settings'
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
  
  def foursquare_oauth_url
    consumer = ::OAuth::Consumer.new(ENV['foursquare_oauth_key'], ENV['foursquare_oauth_secret'], {
      :site               => 'http://foursquare.com',
      :scheme             => :header,
      :http_method        => :post,
      :request_token_path => '/oauth/request_token',
      :access_token_path  => '/oauth/access_token',
      :authorize_path     => '/mobile/oauth/authorize',
      :proxy              => (ENV['HTTP_PROXY'] || ENV['http_proxy'])
    })
    request_token = consumer.get_request_token(:oauth_callback => 'http://' + request.env['HTTP_HOST'] + '/users/update/foursquare/enable')
    session['foursquare_request_token'] = request_token
    request_token.authorize_url
  end
  
  def twitter_oauth_url
    client = ::TwitterOAuth::Client.new({
      :consumer_key    => ENV['twitter_access_token'],
      :consumer_secret => ENV['twitter_access_secret'],
      :token           => ENV['twitter_oauth_key'],
      :secret          => ENV['twitter_oauth_secret']
    })
    request_token = client.request_token(:oauth_callback => 'http://' + request.env['HTTP_HOST'] + '/users/update/twitter/enable')
    session['twitter_request_token'] = request_token
    request_token.authorize_url
  end
  
  def clear_sessions
    current_user = session[:current_user]
    unless current_user.nil?
      redirect_to '/logout' if current_user['enable_foursquare'].nil? or current_user['enable_twitter'].nil?
    end
  end
end
