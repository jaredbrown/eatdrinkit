class AddFoursquareTwitter < ActiveRecord::Migration
  def self.up
    add_column "users", "enable_foursquare", :boolean, :default => false
    add_column "users", "enable_twitter", :boolean, :default => false
    add_column "users", "foursquare_oauth_token", :string
    add_column "users", "foursquare_oauth_secret", :string
    add_column "users", "twitter_oauth_token", :string
    add_column "users", "twitter_oauth_secret", :string
  end

  def self.down
  end
end
