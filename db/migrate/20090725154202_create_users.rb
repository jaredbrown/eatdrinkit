class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :address,                   :string, :limit => 120
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :confirmation_code, :string, :limit => 40
      t.column :password_reset_code,       :string, :limit => 40
      t.column :state, :string, :null => :no, :default => 'passive'
      t.column :confirmed_at,              :datetime
      t.column :activated_at,              :datetime
      t.column :deleted_at,                :datetime
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end
  end

  def self.down
    drop_table "users"
  end
end
