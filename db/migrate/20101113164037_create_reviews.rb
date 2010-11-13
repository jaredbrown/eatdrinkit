class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.column     :menu_item, :string,  :limit => 80, :null => false
      t.column     :liked,     :integer  :limit => 1
      t.references :user       :null => false
      t.references :place,     :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
