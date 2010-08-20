class Session < ActiveRecord::Base
  attr_accessor :email, :password, :match

  belongs_to :person

  before_validation :authenticate_person

  validates_presence_of :match,
    :message => 'for your name and password could not be found',
    :unless => :session_has_been_associated?

  before_save :associate_session_to_person

private
  
  def authenticate_person
    unless session_has_been_associated?
      self.match = Person.find_by_email_and_password(self.email, self.password)
    end
  end

  def associate_session_to_person
    self.person_id ||= self.match.id
  end

  def session_has_been_associated?
    self.person_id
  end
end
