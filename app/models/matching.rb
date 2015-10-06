class Matching < ActiveRecord::Base

  #rails convention will add "_id" after 'top_player' for column name
  belongs_to :top_player, :class_name => "Player"
  #rails convention will add "_id" after 'bottom_player' for column name
  belongs_to :bottom_player, :class_name => "Player"

end
