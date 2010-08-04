require 'digest/sha2'

class User < ActiveRecord::Base
  validates :email, :presence => true, :uniqueness => true

  validates :password, :confirmation => true
  attr_accessor :password_confirmation
  attr_reader :password

  validates_length_of :password, :minimum => 6

  validates :first_name, :presence => true

  class << self
    def authenticate(email, password)
      if user = find_by_email(email)
        if user.hashed_password == encrypt_password(password, user.salt)
          user
        end
      end
    end

    def encrypt_password(password, salt)
      Digest::SHA2.hexdigest(password + "br=-9nkleY" + salt)
    end
  end

  def password=(password)
    @password = password

    if password.present?
      generate_salt
      self.hashed_password = self.class.encrypt_password(password, salt)
    end
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

private

  def generate_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

end
