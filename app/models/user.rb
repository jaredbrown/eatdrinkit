require 'digest/sha1'
require 'aasm'

class User < ActiveRecord::Base
  include AASM
  
  has_many :reviews

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email, :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_presence_of     :username
  validates_length_of       :username, :within => 3..30
  validates_uniqueness_of   :username, :case_sensitive => false
  before_save               :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses confirmation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :password, :password_confirmation, :username

  # AASM Definitions
  aasm_column :state

  aasm_initial_state :unconfirmed
  aasm_state :passive
  aasm_state :unconfirmed, :enter => :make_confirmation_code
  aasm_state :confirmed,   :enter => :do_confirm
  aasm_state :suspended
  aasm_state :deleted, :enter => :do_delete

  aasm_event :register do
    transitions :from => :passive, :to => :unconfirmed, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  aasm_event :confirm do
    transitions :from => :unconfirmed, :to => :confirmed 
  end

  aasm_event :reconfirm do
    transitions :from => [:unconfirmed, :confirmed], :to => :unconfirmed, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  aasm_event :suspend do
    transitions :from => [:passive, :unconfirmed, :confirmed], :to => :suspended
  end
  
  aasm_event :delete do
    transitions :from => [:passive, :unconfirmed, :confirmed, :suspended], :to => :deleted
  end

  aasm_event :unsuspend do
    transitions :from => :suspended, :to => :confirmed,  :guard => Proc.new {|u| !u.confirmed_at.blank? }
    transitions :from => :suspended, :to => :unconfirmed, :guard => Proc.new {|u| !u.confirmation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end

  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find :first, :conditions => {:email => email} # need to get the salt
    u and (u.state == 'confirmed' or u.state == 'unconfirmed') and u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def recently_confirmed?
    @confirmed
  end
  
  def recently_changed_email?
    @changed_email
  end

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    # First update the password_reset_code before setting the
    # reset_password flag to avoid duplicate email notifications.
    update_attribute(:password_reset_code, nil)
    @reset_password = true
  end

  # used in user_observer
  def recently_forgot_password?
    @forgotten_password
  end

  def recently_reset_password?
    @reset_password
  end
  
  def self.find_for_forget(email)
    find :first, :conditions => ['email = ?', email]
  end

  protected
  
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
    self.crypted_password = encrypt(password)
  end
    
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  def make_confirmation_code
    self.deleted_at = self.confirmed_at = nil
    self.confirmation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
  def do_delete
    self.deleted_at = Time.now.utc
  end

  def do_confirm
    @confirmed = true
    self.confirmed_at = Time.now.utc
    self.confirmation_code = nil
  end

  def change_email
    @changed_email = true
  end

  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  # This would be used when undeleting someone
  # It needs some TLC to make it work
  def do_activate
    self.activated_at = Time.now.utc
    self.deleted_at = nil
  end
end
