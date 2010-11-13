require 'foursquare'
class PlacesController < ApplicationController
  #before_filter :login_required
  layout 'default'
  
  # GET /places
  # GET /places.xml
  def index
    oauth_key = '0RYEYEPXJYWGSKPOMOKNH2WV0XBSPHDCWB2BRG520XITTBN0'
    oauth_secret = 'MEWZ1KGL0MYDFZSK1YO143JIKAEIHLH1XMYET3ZGMSUJVUGO'
    
    access_token = 'ZHBKG3JVOWBMZIWCGAKZFMJNNU5LHJZYEPL45UGDGRAVL45O'
    access_secret = 'M12DIPPILIZXXSYL4M1VP1MS5NIV2YPMOSPRHIHCHXXMIPYE'
    
    oauth = Foursquare::OAuth.new(oauth_key, oauth_secret)
    oauth.authorize_from_access(access_token, access_secret)
    foursquare = Foursquare::Base.new(oauth)
    
    foursquare = foursquare.venues :geolat => '39.6873683', :geolong => '-86.31244736', :l => 10
    
    @places = foursquare['groups'][0]['venues']
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => '' }
    end
  end
end