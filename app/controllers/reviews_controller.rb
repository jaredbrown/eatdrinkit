class ReviewsController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  layout 'default'
  
  # GET /reviews/1
  def show
    @review = Review.find(params[:id])
    
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
    @review = Review.new(params[:review])
    @review.user = current_user
    
    oauth = Foursquare::OAuth.new(ENV['oauth_key'], ENV['oauth_secret'])
    oauth.authorize_from_access(ENV['access_token'], ENV['access_secret'])
    foursquare = Foursquare::Base.new(oauth)

logger.info '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> @review: ' + @review.inspect
    
    venue = foursquare.venue :vid => @review.venue_id
    
logger.info '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> venue: ' + venue.inspect
    
    # place = Place.find_or_create_by_venue_id(@review.venue_id, :latitude => venue['geolat'], :longitude => venue['geolong'])
    place = Place.find_by_venue_id(@review.venue_id)
    
    unless(place)
      place = Place.new(:venue_id => @review.venue_id, :latitude => venue['geolat'], :longitude => venue['geolong'])
      outcome = place.save
    end
    
logger.info '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> place: ' + place.inspect
logger.info '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> outcome: ' + outcome.inspect
    
    @review.place = place

    respond_to do |format|
      if @review.save
        flash[:notice] = 'Review posted'
        format.html { redirect_to(@review) }
        format.xml  { render :xml => @review, :status => :created, :location => @review }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
      end
    end
  end
end