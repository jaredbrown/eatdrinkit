require 'foursquare'
class PlacesController < ApplicationController
  #before_filter :login_required
  layout 'default'
  
  # GET /places
  # GET /places.xml
  def results
    foursquare = FoursquareVenueQuery.query(params[:latitude], params[:longitude], '10', 'restaurant')
    
    @venues = foursquare['venues']['group'][0]['venue']
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
    @all_reviews = Review.find_all_by_venue_id(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
end