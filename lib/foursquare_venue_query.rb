class FoursquareVenueQuery
  include HTTParty
  
  base_uri 'api.foursquare.com'
  
  def self.query(geolat, geolong, l = '10', q = '')
    get('/v1/venues?geolat=' + geolat + '&geolong=' + geolong + '&l=' + l.to_s + '&q=' + q).to_hash
  end
end