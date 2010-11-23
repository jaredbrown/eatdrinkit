require 'foursquare'
class PlacesController < ApplicationController
  #before_filter :login_required
  layout 'default'
  
  #def rescue_action(exception)
  #  render :action => 'index'
  #end
  
  # GET /places
  # GET /places.xml
  def results  
    if (params['location'].blank?)
      redirect_to :action => 'index'
      return
    end
    
    @venues = FoursquareVenueQuery.query(params['location']['latitude'], params['location']['longitude'])
    @reviews = {}
    
    @venues.each do |venue|
      review = Review.find_by_venue_id(venue['id'])
      
      unless (review == nil)
        @reviews[venue['id']] = review
      else
        @reviews[venue['id']] = Review.new # I don't like dealing with nils in the view
      end
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => '' }
    end
  end
  
  # GET /places/1
  def show
    oauth = Foursquare::OAuth.new(ENV['oauth_key'], ENV['oauth_secret'])
    oauth.authorize_from_access(ENV['access_token'], ENV['access_secret'])
    foursquare = Foursquare::Base.new(oauth)
    
    @venue = foursquare.venue :vid => params[:id]
    
    unless(params['oauth_verifier'].blank? or session[:request_token].nil?)
      shout = 'Arrived at ' + @venue['name'] + ' using EatDrink.it (http://eatdrink.it).' 
      request_token = session[:request_token]
      access_token = request_token.get_access_token(:oauth_verifier => params['oauth_verifier'])
      access_token.post('http://api.foursquare.com/v1/checkin.json', { :vid => params[:id], :facebook => '1', :twitter => '1', :shout => shout })  
    end
    
    consumer = OAuth::Consumer.new(ENV['oauth_key'], ENV['oauth_secret'], {
      :site => 'http://foursquare.com',
      :scheme => :header,
      :http_method => :post,
      :request_token_path => '/oauth/request_token',
      :access_token_path => '/oauth/access_token',
      :authorize_path => '/mobile/oauth/authenticate'
    })
      
    request_token = consumer.get_request_token(:oauth_callback => request.env['REQUEST_URI'])
      
    session[:request_token] = request_token
    
    @foursquare_url = request_token.authorize_url
    
    if current_user
      @all_reviews = Review.find_all_by_venue_id(params[:id], :conditions => ['user_id != ?', current_user.id])
      @my_reviews = Review.find_all_by_venue_id_and_user_id(params[:id], current_user.id)
    end
    
    @all_reviews ||= Review.find_all_by_venue_id(params[:id])
    @deals = Deal.find_all_by_venue_id(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
end