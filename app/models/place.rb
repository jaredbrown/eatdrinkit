class Place < ActiveRecord::Base
  validates_presence_of :venue_id
  validates_presence_of :latitude
  validates_presence_of :longitude
end