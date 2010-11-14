class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :place
  
  validates_presence_of :menu_item
  validates_presence_of :user_id
  validates_presence_of :place_id
  
  validates_length_of   :menu_item, :within => 3..80
  
  def liked_label
    if(self.liked == 1)
      return "Liked"
    elsif(self.liked == 0)
      return "Disliked"
    else
      return ""
    end
  end
end
