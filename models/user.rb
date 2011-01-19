require 'mongoid'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # new columns need to be added here to be writable through mass assignment
  attr_protected :password_hash, :password_salt
  attr_accessor :password, :password_confirmation

  field :email, :type => String
  field :first_name, :type => String
  field :last_name, :type => String
  field :authentication_token, :type => String  
  field :password_hash, :type => String
  field :password_salt, :type => String

  before_save :prepare_password

  validates_presence_of :first_name, :last_name
  validates_uniqueness_of :email, :allow_blank => true
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validate :check_password, :on => :create

  def to_json 
    super(:except => :password)
  end
  
  # Authentication methods
  
  def check_password
    if self.new_record?
      errors.add(:base, "Password can't be blank") if self.password.blank?
      errors.add(:base, "Password and confirmation does not match") unless self.password == self.password_confirmation
      errors.add(:base, "Password must be at least 4 chars long") if self.password.to_s.size.to_i < 4
    end
  end
  
  def self.authenticate(email, password)
    user = first(:conditions => {:email => email})
    return user if user and user.matching_password?(password)
  end
  
  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end

  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end

end