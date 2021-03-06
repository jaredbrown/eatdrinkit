class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.integer    :venue_id
      t.column     :menu_item, :string,  :limit => 80
      t.column     :liked,     :integer, :limit => 1
      t.references :user
      t.references :place
      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
