class Review < ActiveRecord::Base
  validates_presence_of :menu_item
  validates_presence_of :liked
  validates_presence_of :user_id
  validates_presence_of :place_id
  
  validates_length_of   :menu_item, :is => 80
  
  belongs_to :users
  belongs_to :places
end
