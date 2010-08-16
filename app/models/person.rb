require 'digest/sha2'

class Person < ActiveRecord::Base
  #attr_reader :password

  ENCRYPT = Digest::SHA256

  #has_many :sessions, :dependent => :destroy

  #validates_uniqueness_of :email, :message => "has already been used by someone else"

  #validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    #:on => :create

  #validates_format_of :password, :with => /\A([\x20-\x7E]){6,}\Z/,
    #:message => "must be at least 6 characters",
    #:unless => :password_is_not_being_updated?

  #validates_confirmation_of :password

  #validates_presence_of :first_name

  #after_save :flush_passwords

  def self.find_by_email_and_password(email, password)
    person = self.find_by_email(email)
    if person and person.encrypted_password == ENCRYPT.hexdigest(password + "chrouiNt" + person.salt)
      return person
    end
  end

  def password=(password)
    @password = password
    unless password_is_not_being_updated?
      self.salt = [Array.new(9){rand(256).chr}.join].pack('m').chomp
      self.encrypted_password = ENCRYPT.hexdigest(password + "chrouiNt" + self.salt)
    end
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

private

  def flush_passwords
    @password = @password_confirmation = nil
  end

  def password_is_not_being_updated?
    self.id and self.password.blank?
  end
end
