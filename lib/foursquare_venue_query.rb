class FoursquareVenueQuery
  include HTTParty
  base_uri 'api.foursquare.com'
  
  def self.query(geolat, geolong)
    response = get('/v1/venues?geolat=' + geolat + '&geolong=' + geolong + '&l=50').to_hash['venues']
    
    unless response.nil?
      response = response['group']['venue']
    else
      return Array.new
    end
    
    venues = []
    
    response.each do |venue|
      unless venue['primarycategory'].nil?
        fullpath = venue['primarycategory']['fullpathname']
        if fullpath.starts_with? 'Food' or fullpath.starts_with? 'Nightlife'
          venues.push(venue)
        end
      end
    end
    
    venues
  end
end