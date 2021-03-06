class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.integer :venue_id
      t.string :name
      t.string :latitude
      t.string :longitude
      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end
