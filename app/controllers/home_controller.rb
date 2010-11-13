require 'foursquare'
class HomeController < ApplicationController
  before_filter :login_required
  layout 'default'
  
  # GET /home
  # GET /home.xml
  def index
    # foursquare = Foursquare::Base.new
    # Foursquare::venues :geolat => geolat, :geolong => geolong, :l => 10, :q => 'pizza'
    # foursquare.venues :geolat => geolat, :geolong => geolong, :l => 10
    
    oauth_key = '0RYEYEPXJYWGSKPOMOKNH2WV0XBSPHDCWB2BRG520XITTBN0'
    oauth_secret = 'MEWZ1KGL0MYDFZSK1YO143JIKAEIHLH1XMYET3ZGMSUJVUGO'

    oauth = Foursquare::OAuth.new(oauth_key, oauth_secret)
    
    session[:request_token] = oauth.request_token.token
    session[:request_secret] = oauth.request_token.secret
    
    respond_to do |format|
      format.html { redirect_to oauth.request_token.authorize_url } # index.html.erb
      format.xml  { render :xml => '' }
    end
  end
  
  def authorize
    oauth_key = '0RYEYEPXJYWGSKPOMOKNH2WV0XBSPHDCWB2BRG520XITTBN0'
    oauth_secret = 'MEWZ1KGL0MYDFZSK1YO143JIKAEIHLH1XMYET3ZGMSUJVUGO'

    oauth = Foursquare::OAuth.new(oauth_key, oauth_secret)
    
    access_token, access_secret = oauth.authorize_from_request(session[:request_token], session[:request_secret], 'WZ3FKV')
    
    logger.info '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> access_token: ' + access_token.inspect
    logger.info '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> access_secret: ' + access_secret.inspect
  end
  
  def places
    oauth_key = '0RYEYEPXJYWGSKPOMOKNH2WV0XBSPHDCWB2BRG520XITTBN0'
    oauth_secret = 'MEWZ1KGL0MYDFZSK1YO143JIKAEIHLH1XMYET3ZGMSUJVUGO'
    
    access_token = 'ZHBKG3JVOWBMZIWCGAKZFMJNNU5LHJZYEPL45UGDGRAVL45O'
    access_secret = 'M12DIPPILIZXXSYL4M1VP1MS5NIV2YPMOSPRHIHCHXXMIPYE'
    
    oauth = Foursquare::OAuth.new(oauth_key, oauth_secret)
    oauth.authorize_from_access(access_token, access_secret)
    foursquare = Foursquare::Base.new(oauth)
    
    @places = foursquare.venues :geolat => '39.6873683', :geolong => '-86.31244736', :l => 10
    
    logger.info '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> @places: ' + @places.inspect
  end
end