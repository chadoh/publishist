require 'digest/sha2'

class User < ActiveRecord::Base
  validates :email, :presence => true, :uniqueness => true

  validates :password, :confirmation => true
  attr_accessor :password_confirmation
  attr_reader :password

  validate :password_must_be_present

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

  private

    def password_must_be_present
      errors.add(:password, "Missing password") unless hashed_password.present?
    end

    def generate_salt
      self.salt = self.object_id.to_s + rand.to_s
    end

end
