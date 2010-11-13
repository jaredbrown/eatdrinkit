class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :place
  
  validates_presence_of :menu_item
  validates_presence_of :user_id
  validates_presence_of :place_id
  
  validates_length_of   :menu_item, :within => 3..80
end
