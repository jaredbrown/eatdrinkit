class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string :venue_id,  :null => false
      t.string :latitude,  :null => false
      t.string :longitude, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end
