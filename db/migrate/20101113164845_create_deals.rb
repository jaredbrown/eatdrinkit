class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.integer :venue_id
      t.string :subject, :limit => 60
      t.string :offer, :limit => 100
      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end
