require 'foursquare'
class PlacesController < ApplicationController
  #before_filter :login_required
  layout 'default'
  
  # GET /places
  # GET /places.xml
  def results
    oauth = Foursquare::OAuth.new(ENV['oauth_key'], ENV['oauth_secret'])
    oauth.authorize_from_access(ENV['access_token'], ENV['access_secret'])
    foursquare = Foursquare::Base.new(oauth)
    
    foursquare = foursquare.venues :geolat => params[:latitude], :geolong => params[:longitude], :l => 10
    
    @places = foursquare['groups'][0]['venues']
    
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
    
    @place = foursquare.venue :vid => params[:id]
    @all_reviews = Review.find_by_venue_id(params[:place_id])
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
end