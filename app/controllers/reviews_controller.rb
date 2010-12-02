class ReviewsController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  before_filter :clear_sessions, :only => [:create]
  layout 'default'
  
  # GET /reviews/1
  def show
    @review = Review.find(params[:id])
    
    oauth = Foursquare::OAuth.new(ENV['oauth_key'], ENV['oauth_secret'])
    oauth.authorize_from_access(ENV['access_token'], ENV['access_secret'])
    foursquare = Foursquare::Base.new(oauth)

    @place = foursquare.venue :vid => @review.venue_id
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  # GET /reviews/new
  # GET /reviews/new.xml
  def new
    @review = Review.new
    @review.venue_id = params[:venue_id]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @review }
    end
  end
  
  # POST /reviews
  # POST /reviews.xml
  def create
    @current_user = session[:current_user]
    @review = Review.new(params[:review])
    @review.user = current_user
    
    oauth = Foursquare::OAuth.new(ENV['oauth_key'], ENV['oauth_secret'])
    oauth.authorize_from_access(ENV['access_token'], ENV['access_secret'])
    foursquare = Foursquare::Base.new(oauth)

    venue = foursquare.venue :vid => @review.venue_id
    
    #place = Place.find_or_create_by_venue_id(@review.venue_id, :latitude => venue['geolat'], :longitude => venue['geolong'])
    place = Place.find_by_venue_id(@review.venue_id)
    
    unless(place)
      place = Place.new(:venue_id => @review.venue_id, :name => venue['name'], :latitude => venue['geolat'], :longitude => venue['geolong'])
      outcome = place.save
    end
    
    @review.place = place
    
    # Dislike - 0
    # Like - 1
    if(params[:commit] == 'Like')
      @review.liked = 1
    else
      @review.liked = 0
    end

    respond_to do |format|
      if @review.save
        foursquare_checkin unless !@current_user.enable_foursquare
        tweet unless !current_user.enable_twitter
        flash[:notice] = 'Review posted'
        format.html { redirect_to(@review) }
        format.xml  { render :xml => @review, :status => :created, :location => @review }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  private
    def foursquare_checkin
      consumer = ::OAuth::Consumer.new(ENV['foursquare_oauth_key'], ENV['foursquare_oauth_secret'], {
        :site               => 'http://foursquare.com',
        :scheme             => :header,
        :http_method        => :post,
        :request_token_path => '/oauth/request_token',
        :access_token_path  => '/oauth/access_token',
        :authorize_path     => '/mobile/oauth/authenticate',
        :proxy              => (ENV['HTTP_PROXY'] || ENV['http_proxy'])
      })
      access_token = ::OAuth::AccessToken.new(consumer,
                                              @current_user.foursquare_oauth_token, @current_user.foursquare_oauth_secret)
      result = access_token.post('http://api.foursquare.com/v1/checkin?vid=' + @review.venue_id.to_s + '&twitter=0&facebook=0')
      logger.info '>>>' + result.inspect
    end
    
    def tweet
      client = TwitterOAuth::Client.new({
        :consumer_key    => ENV['twitter_access_token'],
        :consumer_secret => ENV['twitter_access_secret'],
        :token           => @current_user.twitter_oauth_token,
        :secret          => @current_user.twitter_oauth_secret
      })
      
      if (@review.liked == 1)
        liked = 'Liked'
      elsif (@review.liked == 0)
        liked = 'Didn\'t care for'
      else
        return
      end
      client.update liked + ' the ' + @review.menu_item.downcase + ' at ' + @review.place.name + ' using the @EatDrinkit web app (http://eatdrink.it/reviews/' + @review.id.to_s + ')'
    end
    
    def clear_sessions
      current_user = session[:current_user]
      unless current_user.nil?
        redirect_to '/logout' if current_user['enable_foursquare'].nil? or current_user['enable_twitter'].nil?
      end
    end
end