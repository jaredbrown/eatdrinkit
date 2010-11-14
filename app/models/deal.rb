class Deal < ActiveRecord::Base
  validates_presence_of :venue_id
  validates_presence_of :offer
  
  validates_length_of   :subject, :within => 3..60
  validates_length_of   :offer, :within => 3..100
end